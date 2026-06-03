import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/category_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _nomeController = TextEditingController();
  bool _isSaving = false;

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
        nome: nome,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirestoreService().salvarCategoria(categoria);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria cadastrada com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e'),
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
      title: 'Cadastrar Categoria',
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
      confirmButtonAction: _isSaving ? null : _salvarCategoria,
      confirmButtonColor: AppColors.corBordaFocadaInputs,
      padding: const EdgeInsets.all(20.0),
      actionsSpacing: 30,
    );
  }
}
