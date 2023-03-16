import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screen/user_products_screen.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editProduct = Products(
    id: '',
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      await Provider.of<ProductsProvider>(context, listen: false)
          .addProduct(_editProduct);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred!'),
          content: const Text('Something went wrong'),
          actions: [
            ElevatedButton(
              onPressed: () {
                //Navigator.of(context).pop();
                Navigator.of(ctx).pushNamed(UserProductsScreen.routeName);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
        Navigator.of(context).pop();
        //Navigator.of(context).pushNamed(UserProductsScreen.routeName);
      });
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Products(
                          id: _editProduct.id,
                          title: value!,
                          description: _editProduct.description,
                          imageUrl: _editProduct.imageUrl,
                          price: _editProduct.price,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editProduct = Products(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: _editProduct.description,
                          imageUrl: _editProduct.imageUrl,
                          price: double.parse(value!),
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Price cannot be empty';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid price';
                        }
                        if (double.parse(value) < 0) {
                          return 'Wrong Price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editProduct = Products(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: value!,
                          imageUrl: _editProduct.imageUrl,
                          price: _editProduct.price,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description cannot be empty';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editProduct = Products(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                description: _editProduct.description,
                                imageUrl: value!,
                                price: _editProduct.price,
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'ImageUrl cannot be empty';
                              }
                              // if(!value.startsWith('http') || (!value.startsWith('https'))){
                              //   return 'Please enter a valid Url';
                              // }
                              // if(!value.endsWith('.png') || (!value.endsWith('.jpg'))){
                              //   return 'Please enter a valid Image URL';
                              // }
                              return null;
                            },
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
