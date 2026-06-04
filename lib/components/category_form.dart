import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/category_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class CategoryForm extends StatefulWidget {
  final Categoria? categoriaParaEditar;
  const CategoryForm({super.key, this.categoriaParaEditar});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _nomeController = TextEditingController();
  bool _isSaving = false;
  final List<IconData> _iconesDisponiveis = [
    Icons.label_outline,
    Icons.local_gas_station,
    Icons.restaurant,
    Icons.build,
    Icons.receipt_long,
    Icons.two_wheeler,
    Icons.health_and_safety,
    Icons.shopping_cart,
    Icons.attach_money,
    Icons.warning_amber_rounded,
    Icons.home_repair_service,
    Icons.local_parking,
  ];

  late int _iconeSelecionado;

  @override
  void initState() {
    super.initState();
    if (widget.categoriaParaEditar != null) {
      _nomeController.text = widget.categoriaParaEditar!.nome;
      _iconeSelecionado = widget.categoriaParaEditar!.iconCode;
    } else {
      _iconeSelecionado = Icons.label_outline.codePoint;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvarCategoria() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome da categoria.'),
          backgroundColor: AppColors.corErro,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final categoria = Categoria(
        id: widget.categoriaParaEditar?.id,
        nome: nome,
        userId: FirebaseAuth.instance.currentUser!.uid,
        iconCode: _iconeSelecionado,
      );

      if (widget.categoriaParaEditar == null) {
        await FirestoreService().salvarCategoria(categoria);
      } else {
        await FirestoreService().atualizarCategoria(categoria);
      }

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.categoriaParaEditar == null
                ? 'Categoria cadastrada com sucesso!'
                : 'Categoria atualizada com sucesso!',
          ),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: AppColors.corErro,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: widget.categoriaParaEditar == null
          ? 'Cadastrar Categoria'
          : 'Editar Categoria',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nome', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _nomeController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Ex: Pedágio, Multa...',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ícone', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _iconesDisponiveis.map((iconData) {
              final isSelected = iconData.codePoint == _iconeSelecionado;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _iconeSelecionado = iconData.codePoint;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.corDespesa
                        : AppColors.corInputs,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.corDespesa
                          : AppColors.corSombra,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected
                        ? AppColors.corIconeClaro
                        : AppColors.corTexto,
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      confirmButtonText: _isSaving ? 'Salvando...' : 'Salvar',
      confirmButtonIcon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: AppColors.corIcone,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.check_circle_outline, color: AppColors.corIcone),
      confirmButtonAction: _isSaving ? null : _salvarCategoria,
      confirmButtonColor: AppColors.corBordaFocadaInputs,
      padding: const EdgeInsets.all(20.0),
      actionsSpacing: 30,
    );
  }
}
