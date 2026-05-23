import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:motora_app/components/automatic_expense_form.dart';

class ExpensesHistoryPage extends StatefulWidget {
  const ExpensesHistoryPage({super.key});

  @override
  State<ExpensesHistoryPage> createState() => _ExpensesHistoryPageState();
}

class _ExpensesHistoryPageState extends State<ExpensesHistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  void _abrirFormularioDespesa({Despesa? despesa}) {
    showDialog(
      context: context,
      builder: (context) => AutomaticExpenseForm(despesaParaEditar: despesa),
    );
  }

  void _excluirDespesa(String id) async {
    try {
      await _firestoreService.excluirDespesa(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Despesa excluída com sucesso!'),
            backgroundColor: AppColors.corSucesso,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: AppColors.corErro,
          ),
        );
      }
    }
  }

  Future<void> _confirmarExclusao(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.corFundo,
        title: const Text('Excluir Despesa?'),
        content: const Text(
          'Tem certeza que deseja apagar este registro? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.corTexto),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.corExcluir),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      _excluirDespesa(id);
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.corFundo,
      appBar: AppBar(
        backgroundColor: AppColors.corPrincipal,
        title: const Text(
          'Histórico de Despesas',
          style: TextStyle(
            color: AppColors.corTexto,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.corIcone),
      ),
      body: StreamBuilder<List<Despesa>>(
        stream: _firestoreService.buscarDespesas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.corSecundaria),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar despesas.',
                style: TextStyle(color: AppColors.corErro),
              ),
            );
          }

          final despesas = snapshot.data ?? [];
          if (despesas.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma despesa registrada.',
                style: TextStyle(color: AppColors.corHintInputs, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: despesas.length,
            itemBuilder: (context, index) {
              final despesa = despesas[index];
              final dataFormatada = _formatarData(despesa.data);
              final valorFormatado =
                  'R\$ ${despesa.valor.toStringAsFixed(2).replaceAll('.', ',')}';

              return Card(
                color: AppColors.corInputs,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.corBordaInputs),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    despesa.categoria,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.corTexto,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        despesa.descricao,
                        style: const TextStyle(color: AppColors.corTexto),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dataFormatada,
                        style: TextStyle(
                          color: AppColors.corHintInputs,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '- $valorFormatado',
                        style: const TextStyle(
                          color: AppColors.corErro,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.corIcone,
                        ),
                        color: AppColors.corInputs,
                        onSelected: (value) {
                          if (value == 'editar') {
                            _abrirFormularioDespesa(despesa: despesa);
                          } else if (value == 'excluir' && despesa.id != null) {
                            _confirmarExclusao(despesa.id!);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Text(
                              'Editar',
                              style: TextStyle(color: AppColors.corTexto),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Text(
                              'Excluir',
                              style: TextStyle(color: AppColors.corExcluir),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioDespesa(),
        backgroundColor: AppColors.corPrincipal,
        child: const Icon(Icons.add, color: AppColors.corIcone),
      ),
    );
  }
}
