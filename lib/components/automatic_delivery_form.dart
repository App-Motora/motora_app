import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/controllers/delivery_tracking_controller.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/delivery_tracking_result_model.dart';
import 'package:motora_app/services/google_maps_service.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutomaticDeliveryForm extends StatefulWidget {
  const AutomaticDeliveryForm({super.key});

  @override
  State<AutomaticDeliveryForm> createState() => _AutomaticDeliveryFormState();
}

class _AutomaticDeliveryFormState extends State<AutomaticDeliveryForm> {
  static const Color _modalBackgroundColor = Color(0xFFF2EDE4);
  static const Color _fieldBackgroundColor = Colors.white;
  static const Color _disabledFieldColor = Color(0xFFE4E1DA);
  static const Color _accentColor = Color(0xFFF3D080);
  static const Color _successColor = Color(0xFF388E3C);
  static const Color _textColor = Color(0xFF333333);

  final DeliveryTrackingController _trackingController =
      DeliveryTrackingController();
  final TextEditingController _pagamentoController = TextEditingController(
    text: 'R\$ 3,00/km',
  );

  String? restauranteSelecionado = 'Açaí da Praia';
  DeliveryTrackingResult? _finishedResult;
  bool _isFinishing = false;

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
    setState(() {
      _isFinishing = true; // Inicia o loading
    });

    try {
      // 1. Encerra o GPS e pega os dados brutos
      final rawResult = await _trackingController.finish();

      // 2. Consulta o Google Maps para alinhar a rota e dar a KM real
      final googleMapsService = GoogleMapsService();
      final quilometragemLimpa = await googleMapsService.calcularDistanciaReal(
        rawResult.path,
      );

      // 3. Calcula o valor da entrega (exemplo: R$ 3,00 por km)
      final valorCalculado = quilometragemLimpa * 3.0;

      // 4. Cria o objeto do Modelo de Entrega (Nome ajustado para novaEntrega)
      final novaEntrega = Entrega(
        id: '', // O Firestore gera o ID automaticamente
        restaurante: rawResult.restaurant,
        valor: valorCalculado,
        quilometragem: double.parse(quilometragemLimpa.toStringAsFixed(2)),
        data: rawResult.endedAt,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      // 5. SALVA NO FIRESTORE (Passando a variável com o nome correto)
      await FirestoreService().salvarEntregaAutomatica(novaEntrega);

      if (!mounted) return;

      // 6. Atualiza a tela para mostrar o resumo final ao usuário
      setState(() {
        _finishedResult = rawResult; 
      });

      _showMessage('Entrega salva com sucesso!', _successColor);
      
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erro ao processar ou salvar entrega: $e', Colors.red);
      
    } finally {
      // 7. Garante que o botão de "Calculando..." pare de girar, mesmo se der erro
      if (mounted) {
        setState(() {
          _isFinishing = false; 
        });
      }
    }
  }

  Future<void> _closeDialog() async {
    if (_trackingController.isTracking) {
      final shouldClose = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.corFundo,
            title: const Text('Cancelar entrega?'),
            content: const Text(
              'A entrega em andamento será encerrada sem gerar o path final.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Voltar',
                  style: TextStyle(color: AppColors.corTexto),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.corExcluir),
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
    final title = _dialogTitle;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.corFundo,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Flexible(
                      child: Text(
                        title,
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
                      onPressed: _closeDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDialogBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _dialogTitle {
    if (_finishedResult != null) return 'Entrega finalizada';
    if (_trackingController.isTracking) return 'Entrega em andamento';
    return 'Iniciar Entrega';
  }

  Widget _buildDialogBody() {
    if (_finishedResult != null) {
      return _buildResultView(_finishedResult!);
    }

    if (_trackingController.isTracking) {
      return _buildTrackingView();
    }

    return _buildStartForm();
  }

  Widget _buildStartForm() {
    final isStarting = _trackingController.isStarting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Restaurante',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    enabled: !isStarting,
                    width: constraints.maxWidth,
                    initialSelection: restauranteSelecionado,
                    textStyle: const TextStyle(
                      color: AppColors.corTexto,
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
                    dropdownMenuEntries: restaurantes.map((String value) {
                      final isSelected = value == restauranteSelecionado;

                      return DropdownMenuEntry<String>(
                        value: value,
                        label: value,
                        style: AppColors.dropdownMenuItemStyle(isSelected)
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
                color: isStarting ? AppColors.corBordaInputs : AppColors.corBordaFocadaInputs,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.corIcone),
                onPressed: isStarting ? null : () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Perfil de Pagamento',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildEditableTextField(
          controller: _pagamentoController,
          enabled: !isStarting,
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isStarting ? null : _startDelivery,
                icon: isStarting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.corIcone,
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow_outlined,
                        color: AppColors.corIcone,
                      ),
                label: Text(
                  isStarting ? 'Iniciando...' : 'Iniciar Entrega',
                  style: const TextStyle(color: AppColors.corTexto),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.corBordaFocadaInputs,
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
                  style: TextStyle(color: AppColors.corTexto),
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
                  color: AppColors.corSucesso,
                ),
              ),
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
                  color: AppColors.corIcone,
                ),
                label: Text(
                  controller.isPaused ? 'Retomar' : 'Pausar',
                  style: const TextStyle(color: AppColors.corTexto),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.corBordaFocadaInputs,
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
                // Desabilita o clique se estiver carregando
                onPressed: _isFinishing ? null : _finishDelivery,
                // Troca o ícone por um círculo de progresso
                icon: _isFinishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.corErro,
                        ),
                      )
                    : const Icon(
                        Icons.stop_circle_outlined,
                        color: AppColors.corErro,
                      ),
                label: Text(
                  _isFinishing ? 'Calculando...' : 'Finalizar',
                  style: const TextStyle(color: AppColors.corErro),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.corErro, width: 1),
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
            style: const TextStyle(color: AppColors.corErro),
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
                  color: AppColors.corSucesso,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, result),
            icon: const Icon(Icons.check_circle_outline, color: AppColors.corIcone),
            label: const Text('Fechar', style: TextStyle(color: AppColors.corTexto)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.corBordaFocadaInputs,
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
        color: enabled ? AppColors.corInputs : AppColors.corBordaInputs,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
      ),
    );
  }

  Widget _buildReadOnlyInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.corBordaInputs,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.corBordaInputs),
          ),
          child: Text(value, style: TextStyle(color: AppColors.corTexto)),
        ),
      ],
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.corInputs,
      side: BorderSide(color: AppColors.corBordaInputs, width: 1),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      overlayColor: AppColors.corOverlayBotaoCancelar,
    );
  }
}
