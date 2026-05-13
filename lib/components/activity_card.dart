import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';

typedef ActivityCardEditBuilder = Widget Function(BuildContext context);
typedef ActivityCardDeleteCallback = Future<void> Function();

class ActivityCardActionException implements Exception {
  final String message;

  const ActivityCardActionException(this.message);

  @override
  String toString() => message;
}

class ActivityCardActionConfig {
  final ActivityCardEditBuilder? editBuilder;
  final ActivityCardDeleteCallback? onDelete;
  final String editTitle;
  final String? editSubtitle;
  final String deleteTitle;
  final String? deleteSubtitle;
  final String deleteConfirmationTitle;
  final String deleteConfirmationMessage;
  final String deleteConfirmButtonText;
  final String deleteCancelButtonText;
  final String deleteSuccessMessage;
  final String deleteErrorMessage;
  final IconData editIcon;
  final IconData deleteIcon;
  final Color editIconColor;
  final Color deleteIconColor;

  const ActivityCardActionConfig({
    this.editBuilder,
    this.onDelete,
    this.editTitle = 'Editar',
    this.editSubtitle,
    this.deleteTitle = 'Excluir',
    this.deleteSubtitle,
    this.deleteConfirmationTitle = 'Excluir item?',
    this.deleteConfirmationMessage = 'Esta acao nao podera ser desfeita.',
    this.deleteConfirmButtonText = 'Excluir',
    this.deleteCancelButtonText = 'Cancelar',
    this.deleteSuccessMessage = 'Item excluido com sucesso!',
    this.deleteErrorMessage = 'Erro ao excluir item.',
    this.editIcon = Icons.edit,
    this.deleteIcon = Icons.delete_outline,
    this.editIconColor = AppColors.corEditar,
    this.deleteIconColor = AppColors.corExcluir,
  });

  bool get hasActions => editBuilder != null || onDelete != null;

  String resolveDeleteErrorMessage(Object error) {
    if (error is ActivityCardActionException) {
      return error.message;
    }

    return deleteErrorMessage;
  }
}

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String time;
  final String title;
  final String? subtitle;
  final double amount;
  final bool isPositive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ActivityCardActionConfig? actions;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    this.iconColor = AppColors.corIconeClaro,
    required this.time,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isPositive,
    this.onTap,
    this.onLongPress,
    this.actions,
  });

  void _abrirAcoes(BuildContext context) {
    final config = actions;

    if (config == null || !config.hasActions) return;

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
                  color: AppColors.corHintInputs,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              if (config.editBuilder != null)
                ListTile(
                  leading: Icon(config.editIcon, color: config.editIconColor),
                  title: Text(config.editTitle),
                  subtitle: config.editSubtitle == null
                      ? null
                      : Text(config.editSubtitle!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _abrirEditar(context);
                  },
                ),
              if (config.onDelete != null)
                ListTile(
                  leading: Icon(
                    config.deleteIcon,
                    color: config.deleteIconColor,
                  ),
                  title: Text(config.deleteTitle),
                  subtitle: config.deleteSubtitle == null
                      ? null
                      : Text(config.deleteSubtitle!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _confirmarExclusao(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _abrirEditar(BuildContext context) {
    final builder = actions?.editBuilder;

    if (builder == null) return;

    showDialog(context: context, builder: builder);
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final config = actions;
    final onDelete = config?.onDelete;

    if (config == null || onDelete == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.corFundo,
          title: Text(config.deleteConfirmationTitle),
          content: Text(config.deleteConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                config.deleteCancelButtonText,
                style: TextStyle(color: AppColors.corTexto),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                config.deleteConfirmButtonText,
                style: TextStyle(color: config.deleteIconColor),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await onDelete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(config.deleteSuccessMessage),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(config.resolveDeleteErrorMessage(error)),
          backgroundColor: AppColors.corErro,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final cardLongPress =
        onLongPress ??
        (actions?.hasActions == true ? () => _abrirAcoes(context) : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.corInputs,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: AppColors.corSombra,
        surfaceTintColor: AppColors.corInputs,
        child: InkWell(
          onTap: onTap,
          onLongPress: cardLongPress,
          borderRadius: borderRadius,
          splashColor: AppColors.corBordaInputs,
          highlightColor: AppColors.corHintInputs,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.corIcone,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.corTexto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.corHintInputs,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${isPositive ? '+' : '-'}R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isPositive
                        ? AppColors.corEntrega
                        : AppColors.corDespesa,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
