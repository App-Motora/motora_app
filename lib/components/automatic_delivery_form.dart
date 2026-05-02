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

  final TextEditingController _pagamentoController = TextEditingController(
    text: 'R\$3,00/km',
  );

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
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: restauranteSelecionado,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: restaurantes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              restauranteSelecionado = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF3D080),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.black),
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
                        'Iniciar Entrega',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF3D080),
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
                        backgroundColor: Colors.grey.shade200,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        overlayColor: Colors.grey,
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black),
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
