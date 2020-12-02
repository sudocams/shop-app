import '../providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageEditingController = TextEditingController();
  final _imageUrlFocuNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var edittedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValue = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocuNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        edittedProduct =
            Provider.of<Products>(context, listen: false).findbyId(productId);

        _initValue = {
          'title': edittedProduct.title,
          'description': edittedProduct.description,
          'price': edittedProduct.price.toString(),
          // 'imageUrl': edittedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageEditingController.text = edittedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocuNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageEditingController.dispose();
    _imageUrlFocuNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocuNode.hasFocus) {
      // if (_imageEditingController.text.isEmpty ||
      if ((!_imageEditingController.text.startsWith('http') &&
              !_imageEditingController.text.startsWith('https'))
          //||
          // (!_imageEditingController.text.endsWith('.jpg') &&
          //     !_imageEditingController.text.endsWith('.png') &&
          //     !_imageEditingController.text.endsWith('.jpeg'))
          ) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    if (edittedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(edittedProduct.id, edittedProduct);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProducts(edittedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('an error ocurred'),
                  content: Text('something went wrong'),
                  // content: Text(error.toString()),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('okay'))
                  ],
                ));
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm)
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValue['title'],
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please provide a value';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          edittedProduct = Product(
                              title: value,
                              price: edittedProduct.price,
                              description: edittedProduct.description,
                              imageUrl: edittedProduct.imageUrl,
                              id: edittedProduct.id,
                              isFavorite: edittedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue['price'],
                        decoration: InputDecoration(
                          labelText: 'price',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'please enter a number greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          edittedProduct = Product(
                              title: edittedProduct.title,
                              price: double.parse(value),
                              description: edittedProduct.description,
                              imageUrl: edittedProduct.imageUrl,
                              id: edittedProduct.id,
                              isFavorite: edittedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue['description'],
                        decoration: InputDecoration(
                          labelText: 'description',
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a description';
                          }
                          if (value.length < 10) {
                            return 'should be atleast 10 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          edittedProduct = Product(
                              title: edittedProduct.title,
                              price: edittedProduct.price,
                              description: value,
                              imageUrl: edittedProduct.imageUrl,
                              id: edittedProduct.id,
                              isFavorite: edittedProduct.isFavorite);
                        },
                        // textInputAction: TextInputAction.next,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageEditingController.text.isEmpty
                                ? Text('enter a url')
                                : FittedBox(
                                    child: Image.network(
                                      _imageEditingController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              // initialValue: _initValue['imageUrl'],
                              decoration:
                                  InputDecoration(labelText: 'Image url '),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageEditingController,
                              focusNode: _imageUrlFocuNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'please enter a image url';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'please enter a valid url';
                                }
                                // if (!value.endsWith('jpg') &&
                                //     !value.endsWith('png') &&
                                //     !value.endsWith('jpeg')) {
                                //   return 'please enter a valid image url';
                                // }
                                return null;
                              },
                              onSaved: (value) {
                                edittedProduct = Product(
                                    title: edittedProduct.title,
                                    price: edittedProduct.price,
                                    description: edittedProduct.description,
                                    imageUrl: value,
                                    id: edittedProduct.id,
                                    isFavorite: edittedProduct.isFavorite);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
