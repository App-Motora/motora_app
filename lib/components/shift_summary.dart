import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';

class ShiftSummary extends StatelessWidget {
  final String restaurantName;
  final DateTime startedAt;
  final int shiftDeliveryCount;
  final int outsideDeliveryCount;
  final double totalKm;
  final double revenue;
  final double expenses;
  final Future<void> Function()? onFinishShiftPressed;

  const ShiftSummary({
    super.key,
    required this.restaurantName,
    required this.startedAt,
    required this.shiftDeliveryCount,
    required this.outsideDeliveryCount,
    required this.totalKm,
    required this.revenue,
    required this.expenses,
    this.onFinishShiftPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.corMaterial,
      // borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => _openFinishShiftModal(context),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.corInputs.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$shiftDeliveryCount ${shiftDeliveryCount == 1 ? 'entrega' : 'entregas'} no turno',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Finalizar turno',
                icon: const Icon(Icons.pause_circle_outline),
                color: AppColors.corIcone,
                onPressed: () => _openFinishShiftModal(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFinishShiftModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FinishShiftDialog(
          restaurantName: restaurantName,
          startedAt: startedAt,
          shiftDeliveryCount: shiftDeliveryCount,
          outsideDeliveryCount: outsideDeliveryCount,
          totalKm: totalKm,
          revenue: revenue,
          expenses: expenses,
          onFinishShiftPressed: onFinishShiftPressed,
        );
      },
    );
  }
}

class _FinishShiftDialog extends StatefulWidget {
  final String restaurantName;
  final DateTime startedAt;
  final int shiftDeliveryCount;
  final int outsideDeliveryCount;
  final double totalKm;
  final double revenue;
  final double expenses;
  final Future<void> Function()? onFinishShiftPressed;

  const _FinishShiftDialog({
    required this.restaurantName,
    required this.startedAt,
    required this.shiftDeliveryCount,
    required this.outsideDeliveryCount,
    required this.totalKm,
    required this.revenue,
    required this.expenses,
    required this.onFinishShiftPressed,
  });

  @override
  State<_FinishShiftDialog> createState() => _FinishShiftDialogState();
}

class _FinishShiftDialogState extends State<_FinishShiftDialog> {
  DateTime? _finishedAt;
  bool _isFinishing = false;

  bool get _isFinished => _finishedAt != null;

  Future<void> _finishShift() async {
    final action = widget.onFinishShiftPressed;
    if (action == null || _isFinishing) return;

    setState(() => _isFinishing = true);

    try {
      await action();

      if (!mounted) return;
      setState(() => _finishedAt = DateTime.now());
    } catch (_) {
      // The page action already shows the failure message.
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: _isFinished ? 'Resumo do turno' : 'Finalizar turno?',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShiftInfoRow('Restaurante vinculado', widget.restaurantName),
          const SizedBox(height: 10),
          _buildShiftInfoRow(
            'Entregas do restaurante',
            '${widget.shiftDeliveryCount}',
          ),
          const SizedBox(height: 10),
          _buildShiftInfoRow(
            'Entregas por fora',
            '${widget.outsideDeliveryCount}',
          ),
          if (_isFinished) ...[
            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 18),
            _buildShiftInfoRow('Início', _formatTime(widget.startedAt)),
            const SizedBox(height: 10),
            _buildShiftInfoRow('Fim', _formatTime(_finishedAt!)),
            const SizedBox(height: 10),
            _buildShiftInfoRow(
              'Horas rodadas',
              _formatDuration(_finishedAt!.difference(widget.startedAt)),
            ),
            const SizedBox(height: 10),
            _buildShiftInfoRow(
              'Km rodados',
              '${widget.totalKm.toStringAsFixed(1).replaceAll('.', ',')} km',
            ),
            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 18),
            _buildShiftInfoRow(
              'Receita gerada',
              _formatCurrency(widget.revenue),
              valueColor: AppColors.corEntrega,
            ),
            const SizedBox(height: 10),
            _buildShiftInfoRow(
              'Despesa gerada',
              _formatCurrency(widget.expenses),
              valueColor: AppColors.corDespesa,
            ),
            const SizedBox(height: 10),
            _buildShiftInfoRow(
              'Saldo',
              _formatCurrency(widget.revenue - widget.expenses),
              valueColor: AppColors.corSecundaria,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isFinishing
                  ? null
                  : _isFinished
                  ? () => Navigator.pop(context)
                  : _finishShift,
              icon: _isFinishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.corIcone,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _isFinished
                          ? Icons.check_circle_outline
                          : Icons.stop_circle,
                      color: AppColors.corIcone,
                    ),
              label: Text(
                _isFinishing
                    ? 'Finalizando...'
                    : _isFinished
                    ? 'Fechar'
                    : 'Finalizar Turno',
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
        ],
      ),
      showActions: false,
      padding: const EdgeInsets.all(20.0),
      contentSpacing: 8,
    );
  }

  Widget _buildShiftInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.corBordaInputs);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    final normalized = duration.isNegative ? Duration.zero : duration;
    final hours = normalized.inHours;
    final minutes = normalized.inMinutes.remainder(60);

    if (hours == 0) return '${minutes}min';
    return '${hours}h ${minutes}min';
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
