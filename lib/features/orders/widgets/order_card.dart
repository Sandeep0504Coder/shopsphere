import 'package:flutter/material.dart';
import 'package:shopsphere/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = order.orderItems.map((item) => item.photo).toList();
    final isFewImages = images.length <= 3;
    final imageSize = isFewImages ? 54.0 : 36.0;
    final boxWidth = isFewImages ? images.length * (imageSize + 8) : 110.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text('Order #${order.id}'),
        subtitle: Text('Status: ${order.status}\nTotal: \$${order.total.toStringAsFixed(2)}'),
        leading: SizedBox(
          width: boxWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: images.map((img) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    img,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: imageSize),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/order-details', arguments: order.id);
        },
      ),
    );
  }
}