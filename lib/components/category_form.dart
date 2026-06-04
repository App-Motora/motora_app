import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/category_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class CategoryForm extends StatefulWidget {
  final Categoria? categoriaParaEditar; // Recebe dado para edição

  const CategoryForm({super.key, this.categoriaParaEditar});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _nomeController = TextEditingController();
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Se recebeu uma categoria, preenche o campo para edição
    if (widget.categoriaParaEditar != null) {
      _nomeController.text = widget.categoriaParaEditar!.nome;
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
        id: widget.categoriaParaEditar?.id, // Repassa o ID se existir
        nome: nome,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      // Define se vai salvar ou atualizar
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

  Future<void> _excluirCategoria() async {
    setState(() => _isDeleting = true);
    try {
      await FirestoreService().excluirCategoria(
        widget.categoriaParaEditar!.id!,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria excluída com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: AppColors.corErro,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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
          if (widget.categoriaParaEditar != null) ...[
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: _isDeleting ? null : _excluirCategoria,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.corExcluir,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        color: AppColors.corExcluir,
                      ),
                label: const Text(
                  'Excluir esta categoria',
                  style: TextStyle(color: AppColors.corExcluir),
                ),
              ),
            ),
          ],
        ],
      ),
      confirmButtonText: _isSaving ? 'Salvando...' : 'Cadastrar',
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
      confirmButtonAction: _isSaving || _isDeleting ? null : _salvarCategoria,
      confirmButtonColor: AppColors.corBordaFocadaInputs,
      padding: const EdgeInsets.all(20.0),
      actionsSpacing: 30,
    );
  }
}
