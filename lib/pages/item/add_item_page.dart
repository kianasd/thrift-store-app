// lib/pages/add_item_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  final _nameCtrl    = TextEditingController();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _contactCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _uploading = false;

  Future<void> pickImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _image = File(img.path));
  }

  Future<void> _handleUpload() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_image == null) return;

    setState(() => _uploading = true);
    final svc = Provider.of<SupabaseService>(context, listen: false);

    await svc.addItem(
      title:        _titleCtrl.text.trim(),
      desc:         _descCtrl.text.trim(),
      price:        double.tryParse(_priceCtrl.text) ?? 0,
      contact:      _contactCtrl.text.trim(),
      uploaderName: _nameCtrl.text.trim(),
      image:        _image!,
    );

    setState(() => _uploading = false);
    if (svc.error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${svc.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = _image != null && !_uploading;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '✨ Add Your Thrift',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              shadows: [
                Shadow(blurRadius: 8, color: Colors.cyanAccent),
              ],
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                CustomInputField(
                  controller: _titleCtrl,
                  label: 'Item Title',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 16),

                // Description
                CustomInputField(
                  controller: _descCtrl,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Price
                CustomInputField(
                  controller: _priceCtrl,
                  label: 'Price (Php)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Name
                CustomInputField(
                  controller: _nameCtrl,
                  label: 'Your Display Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Contact
                CustomInputField(
                  controller: _contactCtrl,
                  label: 'Contact Email',
                  icon: Icons.contact_mail_outlined,
                ),
                const SizedBox(height: 24),

                // Image picker
                _image == null
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 24),
                  label: const Text(
                    'Choose Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.cyanAccent,
                    ),
                    shadowColor: MaterialStateProperty.all(
                      Colors.cyanAccent.withOpacity(0.7),
                    ),
                  ),
                  onPressed: pickImage,
                )
                    : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _image = null),
                      child: const Text(
                        'Re-pick Image',
                        style: TextStyle(color: Colors.pinkAccent),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Upload button
                ElevatedButton(
                  onPressed: canUpload ? _handleUpload : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith(
                          (states) =>
                      states.contains(MaterialState.disabled)
                          ? Colors.grey
                          : null,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.pinkAccent],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    child: _uploading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                        : const Text(
                      'Upload Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
