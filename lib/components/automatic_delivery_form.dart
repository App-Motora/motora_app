import 'package:flutter/material.dart';

class AutomaticDeliveryForm extends StatefulWidget {
  @override
  State<AutomaticDeliveryForm> createState() => _AutomaticDeliveryFormState();
}

class _AutomaticDeliveryFormState extends State<AutomaticDeliveryForm> {
  String? restauranteSelecionado = 'Açaí da Praia';
  final List<String> restaurantes = [
    'Açaí da Praia',
    'Pizzaria do Bairro',
    'Hambúrguer Caseiro',
  ];

  @override
  void initState() {
    super.initState();
    _trackingController.addListener(_refreshTrackingState);
  }

  @override
  void dispose() {
    _trackingController.removeListener(_refreshTrackingState);
    _trackingController.dispose();
    _pagamentoController.dispose();
    super.dispose();
  }

  void _refreshTrackingState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startDelivery() async {
    final restaurant = restauranteSelecionado;
    final paymentProfile = _pagamentoController.text.trim();

    if (restaurant == null || paymentProfile.isEmpty) {
      _showMessage('Informe restaurante e perfil de pagamento.', Colors.red);
      return;
    }

    await _trackingController.start(
      restaurant: restaurant,
      paymentProfile: paymentProfile,
    );

    if (!mounted) return;

    final errorMessage = _trackingController.errorMessage;
    if (errorMessage != null) {
      _showMessage(errorMessage, Colors.red);
    }
  }

  Future<void> _finishDelivery() async {
    try {
      final result = await _trackingController.finish();

      if (!mounted) return;

      setState(() {
        _finishedResult = result;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Não foi possível finalizar a entrega.', Colors.red);
    }
  }

  Future<void> _closeDialog() async {
    if (_trackingController.isTracking) {
      final shouldClose = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: _modalBackgroundColor,
            title: const Text('Cancelar entrega?'),
            content: const Text(
              'A entrega em andamento será encerrada sem gerar o path final.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Voltar',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFFCC3300)),
                ),
              ),
            ],
          );
        },
      );

      if (shouldClose != true || !mounted) return;
    }

    Navigator.pop(context);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFF2EDE4),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 24),
                  Text(
                    'Iniciar Entrega',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Restaurante',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<String>(
                          width: constraints.maxWidth,
                          initialSelection: restauranteSelecionado,
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor: const WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            surfaceTintColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                          dropdownMenuEntries: restaurantes.map((String value) {
                            final bool isSelected =
                                value == restauranteSelecionado;

                            return DropdownMenuEntry<String>(
                              value: value,
                              label: value,
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      if (isSelected) {
                                        return const Color(0xFFF1F1F1);
                                      }
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return const Color(0xFFF6F6F6);
                                      }
                                      if (states.contains(
                                        WidgetState.hovered,
                                      )) {
                                        return const Color(0xFFF8F8F8);
                                      }
                                      return Colors.white;
                                    }),
                                foregroundColor: const WidgetStatePropertyAll(
                                  Colors.black,
                                ),
                                overlayColor: const WidgetStatePropertyAll(
                                  Color(0x1AF3D080),
                                ),
                              ),
                            );
                          }).toList(),
                          onSelected: (String? newValue) {
                            if (newValue == null) return;

                            setState(() {
                              restauranteSelecionado = newValue;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3D080),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text(
                'Perfil de Pagamento',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _pagamentoController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.play_arrow_outlined,
                        color: Colors.black,
                      ),
                label: Text(
                  isStarting ? 'Iniciando...' : 'Iniciar Entrega',
                  style: const TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
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
                onPressed: isStarting ? null : () => Navigator.pop(context),
                style: _secondaryButtonStyle(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingView() {
    final controller = _trackingController;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyInfo('Restaurante', controller.restaurant ?? ''),
        const SizedBox(height: 12),
        _buildReadOnlyInfo(
          'Perfil de Pagamento',
          controller.paymentProfile ?? '',
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const Text(
                'Quilômetros rodados',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${controller.distanceLabelKm} km',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: _successColor,
                ),
              ),
              // const SizedBox(height: 4),
              // Text(
              //   '${controller.path.length} pontos capturados',
              //   style: TextStyle(color: Colors.grey.shade700),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isPaused
                    ? controller.resume
                    : controller.pause,
                icon: Icon(
                  controller.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.black,
                ),
                label: Text(
                  controller.isPaused ? 'Retomar' : 'Pausar',
                  style: const TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _finishDelivery,
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  color: Color(0xFFCC3300),
                ),
                label: const Text(
                  'Finalizar',
                  style: TextStyle(color: Color(0xFFCC3300)),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCC3300), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorMessage!,
            style: const TextStyle(color: Color(0xFFCC3300)),
          ),
        ],
      ],
    );
  }

  Widget _buildResultView(DeliveryTrackingResult result) {
    final rawPath = result.rawPathText.isEmpty
        ? 'Nenhum ponto capturado.'
        : result.rawPathText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyInfo('Restaurante', result.restaurant),
        const SizedBox(height: 12),
        _buildReadOnlyInfo('Perfil de Pagamento', result.paymentProfile),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const Text(
                'Quilômetros rodados',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.totalDistanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _successColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // const Text('Path bruto', style: TextStyle(fontWeight: FontWeight.w600)),
        // const SizedBox(height: 8),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: SingleChildScrollView(
        //     scrollDirection: Axis.horizontal,
        //     child: SelectableText(
        //       rawPath,
        //       maxLines: 1,
        //       style: const TextStyle(fontSize: 13),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, result),
            icon: const Icon(Icons.check_circle_outline, color: Colors.black),
            label: const Text('Fechar', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: enabled ? _fieldBackgroundColor : _disabledFieldColor,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
