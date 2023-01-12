import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/orders.dart';

class WOrderItem extends StatefulWidget {
  final POrderItem order;
  WOrderItem(this.order);

  @override
  State<WOrderItem> createState() => _WOrderItemState();
}

class _WOrderItemState extends State<WOrderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expanded
          ? min(widget.order.products.length * 20.0 + 110.0, 200)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: (Text('\$${widget.order.amount}')),
              subtitle: Text(
                  DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded
                  ? min(widget.order.products.length * 20.0 + 10.0, 200)
                  : 0,
              child: ListView(
                  children: widget.order.products
                      .map(
                        (e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${e.quantity} x \$${e.price}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
