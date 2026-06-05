import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motora_app/components/filter_search.dart';
import 'package:motora_app/components/financial_summary_card.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/models/shift_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FiltroDatas _filtroAtivo = FiltroDatas.hoje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      drawer: const Menu(selectedIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildFilterRow(),
            Expanded(
              child: StreamBuilder<List<Entrega>>(
                stream: FirestoreService().buscarEntregas(),
                builder: (context, entregasSnap) {
                  return StreamBuilder<List<Despesa>>(
                    stream: FirestoreService().buscarDespesas(),
                    builder: (context, despesasSnap) {
                      return StreamBuilder<List<Turno>>(
                        stream: FirestoreService().buscarTurnos(),
                        builder: (context, turnosSnap) {
                          if (entregasSnap.connectionState == ConnectionState.waiting ||
                              despesasSnap.connectionState == ConnectionState.waiting ||
                              turnosSnap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.corPrincipal),
                            );
                          }

                          final todasEntregas = entregasSnap.data ?? [];
                          final todasDespesas = despesasSnap.data ?? [];
                          final todosTurnos = turnosSnap.data ?? [];

                          // APLICAÇÃO DO FILTRO DE DATA NOS 3 FLUXOS DE DADOS
                          final range = _filtroAtivo.intervalo;
                          final entregas = todasEntregas.where((e) =>
                              !e.data.isBefore(range.start) && !e.data.isAfter(range.end)).toList();
                          final despesas = todasDespesas.where((d) =>
                              !d.data.isBefore(range.start) && !d.data.isAfter(range.end)).toList();
                          final turnos = todosTurnos.where((t) =>
                              !t.iniciadoEm.isBefore(range.start) && !t.iniciadoEm.isAfter(range.end)).toList();

                          return _buildReportContent(entregas, despesas, turnos);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.corPrincipal),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Text(
            'Relatórios',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: FiltroDatas.values.map((filtro) {
          final isSelected = _filtroAtivo == filtro;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filtro.label),
              selected: isSelected,
              onSelected: (_) => setState(() => _filtroAtivo = filtro),
              selectedColor: AppColors.corSecundaria,
              checkmarkColor: AppColors.corFundoMenu,
              backgroundColor: AppColors.corFundoMenu,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.corFundoMenu : AppColors.corTexto,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.corSecundaria : AppColors.corBordaInputs,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _mostrarExplicacao(String titulo, String explicacao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corFundoMenu,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.corTexto),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(color: AppColors.corTexto, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          explicacao,
          style: TextStyle(
            color: AppColors.corTexto.withValues(alpha: 0.8),
            height: 1.4,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Entendi',
              style: TextStyle(color: AppColors.corTexto, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(List<Entrega> entregas, List<Despesa> despesas, List<Turno> turnos) {
    // ==========================================
    // 1. VISÃO GERAL
    // ==========================================
    final faturamentoBruto = entregas.fold<double>(0, (sum, e) => sum + e.valor);
    final totalCustos = despesas.fold<double>(0, (sum, d) => sum + d.valor);
    final lucroLiquido = faturamentoBruto - totalCustos;

    // ==========================================
    // 2. EFICIÊNCIA
    // ==========================================
    final kmTotal = entregas.fold<double>(0, (sum, e) => sum + e.quilometragem);
    final valorPorKm = kmTotal > 0 ? (lucroLiquido / kmTotal) : 0.0;
    final ticketMedio = entregas.isNotEmpty ? (faturamentoBruto / entregas.length) : 0.0;
    
    final custosOperacionais = despesas.where((d) => 
        d.categoria.toLowerCase().contains('combustível') || 
        d.categoria.toLowerCase().contains('manutenção')
    ).fold<double>(0, (sum, d) => sum + d.valor);
    final custoPorKm = kmTotal > 0 ? (custosOperacionais / kmTotal) : 0.0;

    // ==========================================
    // 3. TEMPO E PRODUTIVIDADE (Novas Métricas)
    // ==========================================
    double horasTrabalhadas = 0;
    for (var t in turnos) {
      final fim = t.encerradoEm ?? DateTime.now(); // Se turno está ativo, usa hora atual
      horasTrabalhadas += fim.difference(t.iniciadoEm).inMinutes / 60.0;
    }
    final ganhoPorHora = horasTrabalhadas > 0 ? (lucroLiquido / horasTrabalhadas) : 0.0;

    final ganhosPorDia = <int, double>{};
    for (var e in entregas) {
      ganhosPorDia[e.data.weekday] = (ganhosPorDia[e.data.weekday] ?? 0) + e.valor;
    }
    
    String melhorDiaNome = '-';
    if (ganhosPorDia.isNotEmpty) {
      final melhorDiaEntry = ganhosPorDia.entries.reduce((a, b) => a.value > b.value ? a : b);
      final nomesDias = {
        1: 'Segunda', 2: 'Terça', 3: 'Quarta',
        4: 'Quinta', 5: 'Sexta', 6: 'Sábado', 7: 'Domingo'
      };
      melhorDiaNome = nomesDias[melhorDiaEntry.key] ?? '-';
    }

    // ==========================================
    // 4. RANKINGS (Restaurantes e Categorias)
    // ==========================================
    final Map<String, double> mapaRestaurantes = {};
    for (var e in entregas) {
      mapaRestaurantes[e.restaurante] = (mapaRestaurantes[e.restaurante] ?? 0) + e.valor;
    }
    final topRestaurantes = mapaRestaurantes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, double> mapaCategorias = {};
    for (var d in despesas) {
      mapaCategorias[d.categoria] = (mapaCategorias[d.categoria] ?? 0) + d.valor;
    }
    final topCategorias = mapaCategorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ==========================================
    // RENDERIZAÇÃO
    // ==========================================
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        FinancialSummaryCard(
          receitas: faturamentoBruto,
          despesas: totalCustos,
          saldo: lucroLiquido,
        ),
        const SizedBox(height: 32),

        // NOVAS MÉTRICAS DE VOLUME
        const Text('Volume do Período', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoCard(
              'Total de Entregas', 
              '${entregas.length}', 
              Icons.delivery_dining, 
              AppColors.corTexto,
              'Representa a contagem de todas as entregas concluídas no período selecionado.',
            ),
            const SizedBox(width: 12),
            _buildInfoCard(
              'Km Rodados', 
              '${kmTotal.toStringAsFixed(1)} km', 
              Icons.add_road, 
              AppColors.corTexto,
              'A soma de toda a quilometragem percorrida durante as entregas do período.',
            ),
          ],
        ),
        const SizedBox(height: 32),

        // NOVAS MÉTRICAS DE TEMPO
        const Text('Produtividade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard(
              'Ganho / Hora', 
              ganhoPorHora, 
              Icons.timer, 
              AppColors.corSecundaria,
              'Calculado dividindo o seu Lucro Líquido pelo total de horas trabalhadas nos turnos registrados.',
            ),
            const SizedBox(width: 12),
            _buildInfoCard(
              'Melhor Dia', 
              melhorDiaNome, 
              Icons.calendar_today, 
              AppColors.corDespesa,
              'O dia da semana em que você teve o maior faturamento bruto com entregas.',
            ),
          ],
        ),
        const SizedBox(height: 32),

        // MÉTRICAS DE EFICIÊNCIA
        const Text('Eficiência Operacional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard(
              'Lucro / Km', 
              valorPorKm, 
              Icons.speed, 
              AppColors.corSucesso,
              'Calculado dividindo o seu Lucro Líquido pela quilometragem total rodada nas entregas. Mostra o valor real de cada quilômetro.',
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              'Ticket Médio', 
              ticketMedio, 
              Icons.receipt_long, 
              AppColors.corSecundaria,
              'A média de valor que você ganha por entrega (Faturamento Bruto dividido pelo Total de Entregas).',
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              'Custo / Km', 
              custoPorKm, 
              Icons.build, 
              AppColors.corDespesa,
              'Soma das suas despesas categorizadas como "Combustível" e "Manutenção" dividida pela quilometragem rodada.',
            ),
          ],
        ),
        const SizedBox(height: 32),

        const Text('Ganhos vs Gastos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildComparativeBar(faturamentoBruto, totalCustos),
        const SizedBox(height: 32),

        const Text('Top Restaurantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (topRestaurantes.isEmpty) const Text('Nenhuma entrega neste período.'),
        ...topRestaurantes.take(5).map((entry) => 
          _buildNativeBarChart(entry.key, entry.value, topRestaurantes.first.value, AppColors.corSecundaria)
        ),
        const SizedBox(height: 32),

        const Text('Gastos por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (topCategorias.isEmpty) const Text('Nenhuma despesa neste período.'),
        ...topCategorias.map((entry) => 
          _buildNativeBarChart(entry.key, entry.value, topCategorias.first.value, AppColors.corDespesa)
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Componente para valores Monetários (Atualizado com InkWell)
  Widget _buildMetricCard(String title, double value, IconData icon, Color color, String explicacao) {
    return Expanded(
      child: Material(
        color: AppColors.corInputs,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _mostrarExplicacao(title, explicacao),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.corBordaInputs),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.corTexto)),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Componente para Textos Normais (Atualizado com InkWell)
  Widget _buildInfoCard(String title, String value, IconData icon, Color color, String explicacao) {
    return Expanded(
      child: Material(
        color: AppColors.corInputs,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _mostrarExplicacao(title, explicacao),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.corBordaInputs),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.corTexto)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeBarChart(String label, double value, double maxValue, Color color) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(formatador.format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final percentage = maxValue > 0 ? (value / maxValue) : 0.0;
              return Container(
                height: 12,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeBar(double ganhos, double gastos) {
    final total = ganhos + gastos;
    final percGanhos = total > 0 ? (ganhos / total) : 0.5;
    final percGastos = total > 0 ? (gastos / total) : 0.5;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ganhos', style: TextStyle(color: AppColors.corSucesso, fontWeight: FontWeight.bold)),
            const Text('Gastos', style: TextStyle(color: AppColors.corDespesa, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                Expanded(flex: (percGanhos * 100).toInt(), child: Container(color: AppColors.corSucesso)),
                Expanded(flex: (percGastos * 100).toInt(), child: Container(color: AppColors.corDespesa)),
              ],
            ),
          ),
        )
      ],
    );
  }
}