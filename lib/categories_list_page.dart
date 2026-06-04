import 'package:flutter/material.dart';
import 'package:motora_app/components/category_form.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/category_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({super.key});

  @override
  State<CategoriesListPage> createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      // Altere o selectedIndex de acordo com a posição desta tela no seu Menu
      drawer: const Menu(selectedIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: StreamBuilder<List<Categoria>>(
                stream: FirestoreService().buscarCategorias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.corDespesa,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar categorias.'),
                    );
                  }

                  final categorias = snapshot.data ?? [];

                  if (categorias.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma categoria personalizada criada.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return Card(
                        elevation: 0,
                        color: AppColors
                            .corInputs, // Mantém o padrão visual dos cards
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.corDespesa.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.label_outline,
                              color: AppColors.corDespesa,
                            ),
                          ),
                          title: Text(
                            categoria.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.corEditar,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              // Passa a categoria para o modal abrir no Modo Edição
                              builder: (context) =>
                                  CategoryForm(categoriaParaEditar: categoria),
                            );
                          },
                        ),
                      );
                    },
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
          color: AppColors
              .corDespesa, // Cor vermelha para manter o contexto de despesas
          function: () => showDialog(
            context: context,
            builder: (context) => const CategoryForm(),
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
            'Categorias',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
