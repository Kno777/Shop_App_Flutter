import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  const OrderItem(this.ordera, {super.key});

  final ord.OrderItem ordera;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _exoanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _exoanded ? min(widget.ordera.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.ordera.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.ordera.dateTime),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _exoanded = !_exoanded;
                  });
                },
                icon: Icon(_exoanded ? Icons.expand_less : Icons.expand_more),
              ),
            ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _exoanded ? min(widget.ordera.products.length * 20.0 + 10, 100) : 0,
                child: ListView(
                  children: widget.ordera.products
                      .map((prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${prod.quantity}x \$${prod.price}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
