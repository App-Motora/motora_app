import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/filter_search.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/components/manual_delivery_form.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class DeliveriesHistoryPage extends StatefulWidget {
  const DeliveriesHistoryPage({super.key});

  @override
  State<DeliveriesHistoryPage> createState() => _DeliveriesHistoryPageState();
}

class _DeliveriesHistoryPageState extends State<DeliveriesHistoryPage> {
  final int _activeMenuIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _abrirAcoesEntrega(BuildContext context, Entrega entrega) {
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
                title: const Text('Editar entrega'),
                subtitle: Text(entrega.restaurante),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _abrirEditarEntrega(entrega);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.corExcluir,
                ),
                title: const Text('Excluir entrega'),
                subtitle: const Text('Remover esta entrega do histórico'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _confirmarExclusaoEntrega(entrega);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirEditarEntrega(Entrega entrega) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ManualDeliveryForm(entrega: entrega),
    );
  }

  Future<void> _confirmarExclusaoEntrega(Entrega entrega) async {
    final entregaId = entrega.id;

    if (entregaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar esta entrega.'),
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
          title: const Text('Excluir entrega?'),
          content: Text(
            'A entrega de ${entrega.restaurante} será removida do histórico.',
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
      await FirestoreService().excluirEntrega(entregaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrega excluída com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir entrega.'),
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
              child: StreamBuilder<List<Entrega>>(
                stream: FirestoreService().buscarEntregas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.corEntrega,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar o histórico.'),
                    );
                  }

                  final todasEntregas = snapshot.data ?? [];

                  return FilterSearch<Entrega>(
                    items: todasEntregas,
                    getCategory: (e) => e.restaurante,
                    getDate: (e) => e.data,
                    getSearchText: (e) => e.restaurante,
                    getTitle: (e) => 'Entrega - ${e.restaurante}',
                    getSubtitle: (e) => '${e.quilometragem} km rodados',
                    getAmount: (e) => e.valor,
                    getIsPositive: (e) => true,
                    onLongPress: (entrega) => _abrirAcoesEntrega(context, entrega),
                    searchHint: 'Pesquise a entrega',
                    sectionTitle: 'Histórico',
                    categoryFilterLabel: 'Restaurante',
                    activityCardActions:(entrega) => _activityActionsConfig(entrega)
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
          color: AppColors.corEntrega,
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) => ManualDeliveryForm(),
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
            'Entregas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  ActivityCardActionConfig _activityActionsConfig(Entrega entrega) {
    return ActivityCardActionConfig(
      editTitle: 'Editar entrega',
      editSubtitle: entrega.restaurante,
      deleteTitle: 'Excluir entrega',
      deleteSubtitle: 'Remover esta entrega do histórico',
      deleteConfirmationTitle: 'Excluir entrega?',
      deleteConfirmationMessage:
          'A entrega de ${entrega.restaurante} será removida do histórico.',
      deleteSuccessMessage: 'Entrega excluída com sucesso!',
      deleteErrorMessage: 'Erro ao excluir entrega.',
      editBuilder: (context) => ManualDeliveryForm(entrega: entrega),
      onDelete: () async {
        final entregaId = entrega.id;

        if (entregaId == null) {
          throw const ActivityCardActionException(
            'Não foi possível identificar esta entrega.',
          );
        }

        await FirestoreService().excluirEntrega(entregaId);
      },
    );
  }
}
