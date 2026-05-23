import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';

class GenericModal extends StatefulWidget {
  final String title;
  final Widget content;
  final String? confirmButtonText;
  final Widget? confirmButtonIcon;
  final FutureOr<void> Function()? confirmButtonAction;
  final FutureOr<void> Function()? onClose;
  final bool showActions;
  final String cancelButtonText;
  final Color confirmButtonColor;
  final EdgeInsetsGeometry padding;
  final double contentSpacing;
  final double actionsSpacing;

  const GenericModal({
    super.key,
    required this.title,
    required this.content,
    this.confirmButtonText,
    this.confirmButtonIcon,
    this.confirmButtonAction,
    this.onClose,
    this.showActions = true,
    this.cancelButtonText = 'Cancelar',
    this.confirmButtonColor = AppColors.corBordaFocadaInputs,
    this.padding = const EdgeInsets.fromLTRB(10, 15, 10, 15),
    this.contentSpacing = 0,
    this.actionsSpacing = 0,
  });

  @override
  State<GenericModal> createState() => _GenericModalState();
}

class _GenericModalState extends State<GenericModal> {
  void _close() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.corFundo,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: widget.padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Flexible(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.corTexto,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.corIcone),
                      onPressed: _close,
                    ),
                  ],
                ),
                if (widget.contentSpacing > 0)
                  SizedBox(height: widget.contentSpacing),
                widget.content,
                if (widget.showActions) ...[
                  if (widget.actionsSpacing > 0)
                    SizedBox(height: widget.actionsSpacing),
                  _buildActions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              widget.confirmButtonAction?.call();
            },
            icon: widget.confirmButtonIcon ?? const SizedBox.shrink(),
            label: Text(
              widget.confirmButtonText ?? 'Confirmar',
              style: const TextStyle(color: AppColors.corTexto),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.confirmButtonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _close,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.corInputs,
              side: BorderSide(color: AppColors.corBordaInputs, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              overlayColor: AppColors.corOverlayBotaoCancelar,
            ),
            child: Text(
              widget.cancelButtonText,
              style: const TextStyle(color: AppColors.corTexto),
            ),
          ),
        ),
      ],
    );
  }
}
