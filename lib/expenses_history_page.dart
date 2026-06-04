import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/filter_search.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/components/automatic_expense_form.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class ExpensesHistoryPage extends StatefulWidget {
  const ExpensesHistoryPage({super.key});

  @override
  State<ExpensesHistoryPage> createState() => _ExpensesHistoryPageState();
}

class _ExpensesHistoryPageState extends State<ExpensesHistoryPage> {
  final int _activeMenuIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _abrirAcoesDespesa(BuildContext context, Despesa despesa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.corFundo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.corSombra,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.corEditar),
                title: const Text('Editar despesa'),
                subtitle: Text(despesa.categoria),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _abrirEditarDespesa(despesa);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.corExcluir,
                ),
                title: const Text('Excluir despesa'),
                subtitle: const Text('Remover esta despesa do histórico'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  if (despesa.id != null) {
                    _confirmarExclusaoDespesa(despesa);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirEditarDespesa(Despesa despesa) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          AutomaticExpenseForm(despesaParaEditar: despesa),
    );
  }

  Future<void> _confirmarExclusaoDespesa(Despesa despesa) async {
    final despesaId = despesa.id;

    if (despesaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar esta despesa.'),
          backgroundColor: AppColors.corErro,
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.corFundo,
          title: const Text('Excluir despesa?'),
          content: Text(
            'A despesa de ${despesa.categoria} será removida do histórico.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.corTexto),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.corExcluir),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await FirestoreService().excluirDespesa(despesaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Despesa excluída com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir despesa.'),
          backgroundColor: AppColors.corErro,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      drawer: Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: StreamBuilder<List<Despesa>>(
                stream: FirestoreService().buscarDespesas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.corSecundaria,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar o histórico.'),
                    );
                  }

                  final todasDespesas = snapshot.data ?? [];
                  return FilterSearch<Despesa>(
                    items: todasDespesas,
                    getCategory: (d) => d.categoria,
                    getDate: (d) => d.data,
                    getSearchText: (d) => d.descricao,
                    getTitle: (d) =>
                        d.descricao.isNotEmpty ? d.descricao : d.categoria,
                    getSubtitle: (d) =>
                        d.descricao.isNotEmpty ? d.categoria : '',
                    getAmount: (d) => d.valor,
                    getIsPositive: (d) => false,
                    getDynamicIcon: (d) => IconData(d.iconCode, fontFamily: 'MaterialIcons'),
                    onLongPress: (despesa) =>
                        _abrirAcoesDespesa(context, despesa),
                    searchHint: 'Pesquise a despesa',
                    sectionTitle: 'Histórico',
                    categoryFilterLabel: 'Categoria',
                    activityCardActions: (despesa) =>
                        _activityActionsConfig(despesa),
                    cardIcon: Icons.receipt_long,
                    accentColor: AppColors.corDespesa,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatButton(
          icon: Icons.add,
          color: AppColors.corDespesa,
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) => const AutomaticExpenseForm(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            'Despesas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  ActivityCardActionConfig _activityActionsConfig(Despesa despesa) {
    return ActivityCardActionConfig(
      editTitle: 'Editar despesa',
      editSubtitle: despesa.categoria,
      deleteTitle: 'Excluir despesa',
      deleteSubtitle: 'Remover esta despesa do histórico',
      deleteConfirmationTitle: 'Excluir despesa?',
      deleteConfirmationMessage:
          'A despesa de ${despesa.categoria} será removida do histórico.',
      deleteSuccessMessage: 'Despesa excluída com sucesso!',
      deleteErrorMessage: 'Erro ao excluir despesa.',
      editBuilder: (context) =>
          AutomaticExpenseForm(despesaParaEditar: despesa),
      onDelete: () async {
        final despesaId = despesa.id;

        if (despesaId == null) {
          throw const ActivityCardActionException(
            'Não foi possível identificar esta despesa.',
          );
        }
        await FirestoreService().excluirDespesa(despesaId);
      },
    );
  }
}
