import 'package:flutter/material.dart';
import '../models/tipo_documento_model.dart';

class TipoDocumentoDropdown extends StatelessWidget {
  final List<TipoDocumentoModel> items;
  final int? selectedValue;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;

  const TipoDocumentoDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.isLoading,
    required this.onChanged,
    this.errorMessage,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              'Cargando tipos de documento...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: selectedValue,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Tipo de Documento *',
            prefixIcon: Icon(Icons.assignment_ind_outlined, color: primaryColor),
            filled: true,
            fillColor: Colors.white.withOpacity(0.95),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                item.nombre,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ],
    );
  }
}