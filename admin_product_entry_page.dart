import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:souq_tawfikia/login_page.dart';
import 'home_page.dart'; // للوصول إلى كلاس Product
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AdminProductEntryPage extends StatefulWidget {
  final Function(Product) onProductAdded;

  const AdminProductEntryPage({super.key, required this.onProductAdded});

  @override
  State<AdminProductEntryPage> createState() => _AdminProductEntryPageState();
}

class _AdminProductEntryPageState extends State<AdminProductEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _remainingController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // خصم
  bool _discountEnabled = false;
  double? _discountValue;
  String _discountType = 'percentage'; // 'percentage' or 'fixed'

  bool _isSubmitting = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _productType = 'part';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _remainingController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _imageUrlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في اختيار الصورة: $e')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('مكتبة الصور'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImageToStorage(XFile imageFile, String productId) async {
    try {
      final fileName =
          'product_images/${productId}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      final ref = firebase_storage.FirebaseStorage.instance.ref(fileName);
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في رفع الصورة: $e')),
        );
      }
      return null;
    }
  }

  double _calculatePriceAfterDiscount(double price) {
    if (!_discountEnabled || _discountValue == null) return price;
    if (_discountType == 'percentage') {
      double discountAmount = price * (_discountValue! / 100);
      double discountedPrice = price - discountAmount;
      return discountedPrice > 0 ? discountedPrice : 0;
    } else {
      double discountedPrice = price - _discountValue!;
      return discountedPrice > 0 ? discountedPrice : 0;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null && _imageUrlController.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرجاء اختيار صورة أو إدخال رابط الصورة')),
          );
        }
        return;
      }

      setState(() => _isSubmitting = true);

      final newProductId =
          FirebaseFirestore.instance.collection('products').doc().id;
      String? finalImageUrl;

      if (_imageFile != null) {
        finalImageUrl = await _uploadImageToStorage(_imageFile!, newProductId);
        if (finalImageUrl == null) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }
      } else if (_imageUrlController.text.trim().isNotEmpty) {
        final urlText = _imageUrlController.text.trim();
        final uri = Uri.tryParse(urlText);
        if (uri == null || !uri.hasAbsolutePath) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الرجاء إدخال رابط صورة صحيح')),
            );
            setState(() => _isSubmitting = false);
          }
          return;
        }
        finalImageUrl = urlText;
      }

      if (finalImageUrl == null || finalImageUrl.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم تحديد مصدر الصورة بشكل صحيح')),
          );
          setState(() => _isSubmitting = false);
        }
        return;
      }

      double price = double.tryParse(_priceController.text) ?? 0.0;
      double priceAfterDiscount = _calculatePriceAfterDiscount(price);

      final productData = {
        'id': newProductId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'remaining': int.tryParse(_remainingController.text.trim()) ?? 0,
        'type': _productType,
        'imageUrl': finalImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'discountEnabled': _discountEnabled,
        'discountType': _discountEnabled ? _discountType : null,
        'discountValue': _discountEnabled ? _discountValue : null,
        'priceAfterDiscount': _discountEnabled ? priceAfterDiscount : null,
      };

      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(newProductId)
            .set(productData);

        final newProductForCallback = Product(
          id: newProductId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: priceAfterDiscount,
          remaining: int.tryParse(_remainingController.text) ?? 0,
          type: _productType,
          imageUrl: finalImageUrl,
        );
        widget.onProductAdded(newProductForCallback);

        if (mounted) {
          bool? addAnother = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('تم رفع المنتج بنجاح'),
              content: const Text('هل تريد إضافة منتج آخر؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('لا'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('نعم'),
                ),
              ],
            ),
          );

          if (addAnother == true) {
            // إعادة تعيين النموذج لإضافة منتج جديد
            _formKey.currentState!.reset();
            setState(() {
              _imageFile = null;
              _imageUrlController.clear();
              _productType = 'part';
              _discountEnabled = false;
              _discountValue = null;
              _discountType = 'percentage';
            });
          } else {
            // العودة لصفحة تسجيل الدخول (login)
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => login_page()));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في إضافة المنتج إلى Firestore: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double currentPrice = double.tryParse(_priceController.text) ?? 0.0;
    double discountedPrice = _calculatePriceAfterDiscount(currentPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(File(_imageFile!.path)),
                                fit: BoxFit.cover,
                              )
                            : _imageUrlController.text.trim().isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_imageUrlController.text.trim()),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_imageFile == null &&
                              _imageUrlController.text.trim().isEmpty)
                          ? Icon(Icons.image_search_outlined,
                              size: 60, color: Colors.grey.shade500)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('اختيار صورة من الجهاز'),
                      onPressed: () => _showImageSourceActionSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'أو أدخل رابط الصورة (URL)',
                  hintText: 'https://example.com/image.png',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _imageFile = null;
                    });
                  } else {
                    setState(() {});
                  }
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'الرجاء إدخال رابط صحيح';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المنتج',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال وصف المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'سعر المنتج (جنيه)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال سعر المنتج';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'الرجاء إدخال سعر صحيح أكبر من الصفر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              if (_discountEnabled)
                Text(
                  'السعر بعد الخصم: ${discountedPrice.toStringAsFixed(2)} جنيه',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: 16),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تمكين الخصم'),
                value: _discountEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _discountEnabled = value;
                    if (!value) {
                      _discountValue = null;
                    }
                  });
                },
              ),
              if (_discountEnabled) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'قيمة الخصم',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.percent),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) {
                          setState(() {
                            _discountValue = double.tryParse(val);
                          });
                        },
                        validator: (val) {
                          if (_discountEnabled) {
                            if (val == null || val.isEmpty) {
                              return 'الرجاء إدخال قيمة الخصم';
                            }
                            final d = double.tryParse(val);
                            if (d == null || d <= 0) {
                              return 'الرجاء إدخال قيمة صحيحة أكبر من صفر';
                            }
                            if (_discountType == 'percentage' && d > 100) {
                              return 'قيمة الخصم بالنسبة المئوية لا يمكن أن تتجاوز 100';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _discountType,
                      items: const [
                        DropdownMenuItem(
                          value: 'percentage',
                          child: Text('نسبة مئوية %'),
                        ),
                        DropdownMenuItem(
                          value: 'fixed',
                          child: Text('قيمة ثابتة'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _discountType = val ?? 'percentage';
                        });
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _remainingController,
                decoration: const InputDecoration(
                  labelText: 'الكمية المتاحة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الكمية المتاحة';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'الرجاء إدخال كمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _productType,
                decoration: const InputDecoration(
                  labelText: 'نوع المنتج',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'part',
                    child: Text('قطع غيار'),
                  ),
                  DropdownMenuItem(
                    value: 'service',
                    child: Text('إكسسوارات'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _productType = value ?? 'part';
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إضافة المنتج'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
