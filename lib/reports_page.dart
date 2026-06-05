import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motora_app/components/filter_search.dart'; // Importa o FiltroDatas
import 'package:motora_app/components/financial_summary_card.dart'; // Seu card de resumo
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // O cérebro do filtro reaproveitado do seu FilterSearch
  FiltroDatas _filtroAtivo = FiltroDatas.esteMes; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      drawer: const Menu(selectedIndex: 3), // Ajuste o index conforme seu Menu
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
                      if (entregasSnap.connectionState == ConnectionState.waiting ||
                          despesasSnap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.corPrincipal),
                        );
                      }

                      final todasEntregas = entregasSnap.data ?? [];
                      final todasDespesas = despesasSnap.data ?? [];

                      // 1. APLICANDO O FILTRO DE DATA
                      final range = _filtroAtivo.intervalo;
                      final entregas = todasEntregas.where((e) =>
                          !e.data.isBefore(range.start) && !e.data.isAfter(range.end)).toList();
                      final despesas = todasDespesas.where((d) =>
                          !d.data.isBefore(range.start) && !d.data.isAfter(range.end)).toList();

                      return _buildReportContent(entregas, despesas);
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
              label: Text(filtro.label), // Reaproveitado da extensão do filter_search
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

  Widget _buildReportContent(List<Entrega> entregas, List<Despesa> despesas) {
    // ==========================================
    // CÁLCULOS DOS INDICADORES
    // ==========================================
    
    // 1. Visão Geral
    final faturamentoBruto = entregas.fold<double>(0, (sum, e) => sum + e.valor);
    final totalCustos = despesas.fold<double>(0, (sum, d) => sum + d.valor);
    final lucroLiquido = faturamentoBruto - totalCustos;

    // 2. Eficiência
    final kmTotal = entregas.fold<double>(0, (sum, e) => sum + e.quilometragem);
    final valorPorKm = kmTotal > 0 ? (lucroLiquido / kmTotal) : 0.0;
    final ticketMedio = entregas.isNotEmpty ? (faturamentoBruto / entregas.length) : 0.0;
    
    // Filtra apenas Manutenção e Combustível para o Custo/KM
    final custosOperacionais = despesas.where((d) => 
        d.categoria.toLowerCase().contains('combustível') || 
        d.categoria.toLowerCase().contains('manutenção')
    ).fold<double>(0, (sum, d) => sum + d.valor);
    
    final custoPorKm = kmTotal > 0 ? (custosOperacionais / kmTotal) : 0.0;

    // 3. Ganhos por Restaurante (Top 5)
    final Map<String, double> mapaRestaurantes = {};
    for (var e in entregas) {
      mapaRestaurantes[e.restaurante] = (mapaRestaurantes[e.restaurante] ?? 0) + e.valor;
    }
    final topRestaurantes = mapaRestaurantes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 4. Despesas por Categoria
    final Map<String, double> mapaCategorias = {};
    for (var d in despesas) {
      mapaCategorias[d.categoria] = (mapaCategorias[d.categoria] ?? 0) + d.valor;
    }
    final topCategorias = mapaCategorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ==========================================
    // RENDERIZAÇÃO DA TELA
    // ==========================================
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. VISÃO GERAL (Usa o seu componente existente)
        FinancialSummaryCard(
          receitas: faturamentoBruto,
          despesas: totalCustos,
          saldo: lucroLiquido,
        ),
        const SizedBox(height: 24),

        // 2. MÉTRICAS DE EFICIÊNCIA
        const Text('Eficiência', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard('Lucro / Km', valorPorKm, Icons.speed, AppColors.corSucesso),
            const SizedBox(width: 12),
            _buildMetricCard('Ticket Médio', ticketMedio, Icons.receipt_long, AppColors.corSecundaria),
            const SizedBox(width: 12),
            _buildMetricCard('Custo / Km', custoPorKm, Icons.build, AppColors.corDespesa),
          ],
        ),
        const SizedBox(height: 32),

        // 5. HISTÓRICO COMPARATIVO (Resumo visual do período)
        const Text('Ganhos vs Gastos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildComparativeBar(faturamentoBruto, totalCustos),
        const SizedBox(height: 32),

        // 3. ANÁLISE DE GANHOS (Restaurantes)
        const Text('Top Restaurantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (topRestaurantes.isEmpty) const Text('Nenhuma entrega neste período.'),
        ...topRestaurantes.take(5).map((entry) => 
          _buildNativeBarChart(entry.key, entry.value, topRestaurantes.first.value, AppColors.corSecundaria)
        ),
        const SizedBox(height: 32),

        // 4. ANÁLISE DE GASTOS (Categorias)
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

  // ==========================================
  // COMPONENTES VISUAIS (GRÁFICOS NATIVOS)
  // ==========================================

  Widget _buildMetricCard(String title, double value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.corInputs,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.corBordaInputs),
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
    );
  }

  // Gráfico de barra de progresso nativo para os Rankings
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

  // Barra de comparação de Gastos vs Ganhos
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