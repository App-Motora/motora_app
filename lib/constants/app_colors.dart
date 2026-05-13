import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static const Color corFundo = Color(0xFFF5F2E9);
  static const Color corTexto = Color(0xFF000000);
  static const Color corSecundaria = Color(0xFF4FA8FF);
  static const Color corDespesa = Color(0xFFFF7E55);
  static const Color corEntrega = Color(0xFF388E3C);
  static const Color corPrincipal = Color(0xFFF7E18B);
  static const Color corIcone = Color(0xFF000000);
  static Color corFundoMenu = Colors.white;

  static const Color corErro = Color(0xFFFF4C4C);
  static const Color corSair = Color(0xFFFF4C4C);
  static const Color corExcluir = Color(0xFFCC3300);
  static const Color corSucesso = Color(0xFF388E3C);
  static const Color corEditar = Color(0xFF388E3C);

  static const Color corInputs = Color(0xFFFFFFFF);
  static const Color corBordaFocadaInputs = Color(0xFFF3D080);
  static Color corBordaInputs = Colors.grey.shade300;
  static Color corHintInputs = Colors.black38;

  static Color corCursorSelecao = Colors.orange;

  static Color corMaterial = Colors.transparent;
  static const Color corDropdownItemIsSelected = Color(0xFFF1F1F1);
  static const Color corDropdownItemSelected = Color(0xFFF6F6F6);
  static const Color corHovered = Color(0xFFF8F8F8);
  static const Color corOverlayDropdownItem = Color(0x1AF3D080);
  static  Color corOverlayBotaoCancelar = Colors.grey;

  static Color corSombra = Colors.black26;
  static const Color corIconeClaro = Colors.white;
  
  static ButtonStyle dropdownMenuItemStyle(bool isSelected) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (isSelected) {
          return AppColors.corDropdownItemIsSelected;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.corDropdownItemSelected;
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.corHovered;
        }
        return AppColors.corInputs;
      }),
      foregroundColor: const WidgetStatePropertyAll(
        AppColors.corTexto,
      ),
      overlayColor: const WidgetStatePropertyAll(
        AppColors.corOverlayDropdownItem,
      ),
    );
  }}