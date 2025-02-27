// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:bookmywod_admin/services/database/models/catagory_model.dart';
import 'package:bookmywod_admin/services/database/models/trainer_model.dart';
import 'package:bookmywod_admin/services/database/supabase_storage/supabase_db.dart';
import 'package:bookmywod_admin/shared/custom_text_field.dart';
import 'package:bookmywod_admin/shared/custom_button.dart';
import 'package:bookmywod_admin/shared/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateCatagoryView extends StatefulWidget {
  final SupabaseDb supabaseDb;
  final TrainerModel trainerModel;
  const CreateCatagoryView({
    super.key,
    required this.supabaseDb,
    required this.trainerModel,
  });

  @override
  State<CreateCatagoryView> createState() => _CreateCatagoryViewState();
}

class _CreateCatagoryViewState extends State<CreateCatagoryView> {
  late final TextEditingController _catagoryNameController;
  late final TextEditingController _catagoryFeaturesController;
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      if (mounted) {
        showSnackbar(context, 'No image selected', type: SnackbarType.error);
      }
      return;
    }

    try {
      final imageBytes = await pickedFile.readAsBytes();
      final fileExt = pickedFile.path.split('.').last;
      final fileName =
          'category/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Check file size
      final fileSize = imageBytes.length / (1024 * 1024);
      if (fileSize > 20) {
        if (mounted) {
          showSnackbar(context, 'Image size should be less than 20MB',
              type: SnackbarType.error);
        }
        return;
      }

      await Supabase.instance.client.storage.from('category').uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('category')
          .getPublicUrl(fileName);

      setState(() {
        _pickedImage = File(pickedFile.path);
        _imageUrl = imageUrl;
      });

      if (mounted) {
        showSnackbar(
          context,
          'Image uploaded successfully!',
          type: SnackbarType.success,
        );
      }
    } on StorageException catch (e) {
      if (mounted) {
        showSnackbar(context, 'Failed to upload image: ${e.message}',
            type: SnackbarType.error);
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Unexpected error occurred: $e',
            type: SnackbarType.error);
      }
    } finally {}
  }

  @override
  void initState() {
    _catagoryNameController = TextEditingController();
    _catagoryFeaturesController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _catagoryNameController.dispose();
    _catagoryFeaturesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Catagory'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                label: 'Catagory Name',
                controller: _catagoryNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Features',
                controller: _catagoryFeaturesController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload, size: 50, color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'Upload Image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _pickedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Create Catagory',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      var createdCatagory = CatagoryModel.newCatagory(
                        gymId: widget.trainerModel.gymId,
                        uuidOfCreator: widget.trainerModel.trainerId!,
                        image: _imageUrl,
                        name: _catagoryNameController.text,
                        features: _catagoryFeaturesController.text.split(','),
                      );

                      await widget.supabaseDb.createCatagory(createdCatagory);

                      showSnackbar(
                        context,
                        'Catagory created successfully',
                        type: SnackbarType.success,
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      showSnackbar(
                        context,
                        'Error creating category: ${e.toString()}',
                        type: SnackbarType.error,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
