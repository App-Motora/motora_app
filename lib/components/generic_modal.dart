import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';

class GenericModal extends StatefulWidget {
  final String title;
  final Widget content;
  final String confirmButtonText;
  final Icon? confirmButtonIcon;
  final Function? confirmButtonAction;

  const GenericModal({
    required this.title,
    required this.content,
    required this.confirmButtonText,
    this.confirmButtonIcon,
    this.confirmButtonAction,
  });

  @override
  State<GenericModal> createState() => _GenericModalState();
}

class _GenericModalState extends State<GenericModal> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.corFundo,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 24),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.corTexto,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.corIcone),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              widget.content,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: widget.confirmButtonIcon ?? SizedBox.shrink(),
                      label: Text(
                        widget.confirmButtonText,
                        style: TextStyle(color: AppColors.corTexto),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.corBordaFocadaInputs,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.corInputs,
                        side: BorderSide(color: AppColors.corBordaInputs, width: 1),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        overlayColor: AppColors.corOverlayBotaoCancelar,
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.corTexto),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
