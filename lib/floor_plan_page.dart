import 'package:flutter/material.dart';

import 'data/admin_database.dart';
import 'models/admin_booth_map.dart';
import 'models/admin_booth_type.dart';
import 'models/booth.dart';
import 'models/exhibition_event.dart';
import 'pages/cart_page.dart';
import 'utils/asset_path.dart';
import 'widgets/phone_frame.dart';

class FloorPlanPage extends StatefulWidget {
  const FloorPlanPage({
    super.key,
    required this.event,
    required this.exhibitorId,
    required this.cart,
    required this.onSubmitted,
  });

  final ExhibitionEvent event;
  final int exhibitorId;
  final List<Booth> cart;
  final VoidCallback onSubmitted;

  @override
  State<FloorPlanPage> createState() => _FloorPlanPageState();
}

class _FloorPlanPageState extends State<FloorPlanPage> {
  final db = AdminDatabase.instance;
  AdminBoothMap? selectedBooth;
  List<AdminBoothMap> booths = [];
  List<AdminBoothType> boothTypes = [];
  String? imagePath;
  bool blockAdjacent = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await db.fetchFloorPlanForEvent(widget.event.id);
    final maps = await db.fetchBoothsForEvent(widget.event.id);
    final types = await db.fetchBoothTypesForEvent(widget.event.id);
    final events = await db.fetchEvents();
    final eventRecord = events.isEmpty
        ? null
        : events.firstWhere(
            (event) => event.id == widget.event.id,
            orElse: () => events.first,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      imagePath = plan?.imagePath;
      booths = maps.map((booth) {
        final inCart = widget.cart.any(
          (item) => item.eventId == widget.event.id && item.id == booth.boothId,
        );
        if (inCart) {
          return AdminBoothMap(
            id: booth.id,
            boothId: booth.boothId,
            boothTypeId: booth.boothTypeId,
            floorPlanId: booth.floorPlanId,
            x: booth.x,
            y: booth.y,
            width: booth.width,
            height: booth.height,
            status: 'selected',
            attributes: booth.attributes,
          );
        }
        return booth;
      }).toList();
      boothTypes = types;
      blockAdjacent = eventRecord?.blockAdjacent ?? true;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xff55bd69);
      case 'booked':
        return const Color(0xffd9534f);
      case 'pending':
        return const Color(0xfff0ad4e);
      case 'selected':
        return const Color(0xff4389f4);
      default:
        return const Color(0xff9b9b9b);
    }
  }

  AdminBoothType? _typeFor(int typeId) {
    try {
      return boothTypes.firstWhere((type) => type.id == typeId);
    } catch (_) {
      return null;
    }
  }

  bool _isAdjacent(String a, String b) {
    final regex = RegExp(r'^([A-Za-z]+)(\d+)$');
    final matchA = regex.firstMatch(a);
    final matchB = regex.firstMatch(b);
    if (matchA == null || matchB == null) {
      return false;
    }
    if (matchA.group(1) != matchB.group(1)) {
      return false;
    }
    final numA = int.tryParse(matchA.group(2) ?? '');
    final numB = int.tryParse(matchB.group(2) ?? '');
    if (numA == null || numB == null) {
      return false;
    }
    return (numA - numB).abs() == 1;
  }

  bool _blockedByAdjacency(AdminBoothMap booth) {
    if (!blockAdjacent) {
      return false;
    }
    final blocked = booths.where(
      (other) =>
          other.id != booth.id &&
          (other.status == 'booked' || other.status == 'pending') &&
          _isAdjacent(booth.boothId, other.boothId),
    );
    return blocked.isNotEmpty;
  }

  bool _isInCart(AdminBoothMap booth) {
    return widget.cart.any(
      (item) => item.eventId == widget.event.id && item.id == booth.boothId,
    );
  }

  void _selectBooth(AdminBoothMap booth) {
    if (booth.status == 'selected' && _isInCart(booth)) {
      setState(() => selectedBooth = booth);
      return;
    }
    if (booth.status != 'available') {
      return;
    }
    if (_blockedByAdjacency(booth)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adjacent booth is blocked.')),
      );
      return;
    }
    setState(() => selectedBooth = booth);
  }

  void _addToCart(AdminBoothMap booth) {
    final type = _typeFor(booth.boothTypeId);
    if (type == null) {
      return;
    }
    final hasOtherEvent = widget.cart.any(
      (item) => item.eventId != widget.event.id,
    );
    if (hasOtherEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submit or clear the current event cart first.'),
        ),
      );
      return;
    }
    final already = widget.cart.any(
      (item) => item.eventId == widget.event.id && item.id == booth.boothId,
    );
    if (already) {
      return;
    }
    setState(() {
      widget.cart.add(
        Booth(
          id: booth.boothId,
          status: 'selected',
          price: type.price,
          typeName: type.name,
          sizeLabel: '10x10 ft',
          eventId: widget.event.id,
          eventName: widget.event.title,
        ),
      );
      booths = booths
          .map(
            (item) => item.id == booth.id
                ? AdminBoothMap(
                    id: item.id,
                    boothId: item.boothId,
                    boothTypeId: item.boothTypeId,
                    floorPlanId: item.floorPlanId,
                    x: item.x,
                    y: item.y,
                    width: item.width,
                    height: item.height,
                    status: 'selected',
                    attributes: item.attributes,
                  )
                : item,
          )
          .toList();
      selectedBooth = AdminBoothMap(
        id: booth.id,
        boothId: booth.boothId,
        boothTypeId: booth.boothTypeId,
        floorPlanId: booth.floorPlanId,
        x: booth.x,
        y: booth.y,
        width: booth.width,
        height: booth.height,
        status: 'selected',
        attributes: booth.attributes,
      );
    });
  }

  void _removeFromCart(AdminBoothMap booth) {
    setState(() {
      widget.cart.removeWhere(
        (item) => item.eventId == widget.event.id && item.id == booth.boothId,
      );
      booths = booths
          .map(
            (item) => item.id == booth.id
                ? AdminBoothMap(
                    id: item.id,
                    boothId: item.boothId,
                    boothTypeId: item.boothTypeId,
                    floorPlanId: item.floorPlanId,
                    x: item.x,
                    y: item.y,
                    width: item.width,
                    height: item.height,
                    status: 'available',
                    attributes: item.attributes,
                  )
                : item,
          )
          .toList();
      selectedBooth = AdminBoothMap(
        id: booth.id,
        boothId: booth.boothId,
        boothTypeId: booth.boothTypeId,
        floorPlanId: booth.floorPlanId,
        x: booth.x,
        y: booth.y,
        width: booth.width,
        height: booth.height,
        status: 'available',
        attributes: booth.attributes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibitor Portal'),
        backgroundColor: const Color(0xffd9d9d9),
        foregroundColor: Colors.black,
      ),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          children: [
            if (imagePath != null)
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          normalizeFloorPlanAssetPath(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Image not found')),
                        ),
                      ),
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;

                            return Stack(
                              children: [
                                for (final booth in booths)
                                  Positioned(
                                    left: booth.x * width,
                                    top: booth.y * height,
                                    width: booth.width * width,
                                    height: booth.height * height,
                                    child: GestureDetector(
                                      onTap: () => _selectBooth(booth),
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _statusColor(booth.status),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          booth.boothId,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (imagePath == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Floor plan is not available yet.')),
              ),
            const SizedBox(height: 16),
            const Text(
              'Booth details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (selectedBooth == null)
              const Text('Tap an available booth to see details.'),
            if (selectedBooth != null) _buildDetailCard(selectedBooth!),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: widget.cart.isEmpty
                  ? null
                  : () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CartPage(
                            cart: widget.cart,
                            exhibitorId: widget.exhibitorId,
                            onSubmitted: widget.onSubmitted,
                          ),
                        ),
                      );
                      await _load();
                    },
              child: const Text('Open Cart'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(AdminBoothMap booth) {
    final type = _typeFor(booth.boothTypeId);
    final price = type?.price ?? 0;
    final inCart = _isInCart(booth);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff1ecec),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xffbcbcbc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booth ${booth.boothId} Details:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Type: ${type?.name ?? 'Unknown'}'),
                const Text('Size: 10x10 ft'),
                Text('Price: RM ${price.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: inCart
                        ? () => _removeFromCart(booth)
                        : () => _addToCart(booth),
                    style: FilledButton.styleFrom(
                      backgroundColor: inCart
                          ? const Color(0xffb84a4a)
                          : const Color(0xff808080),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(inCart ? 'Remove from Cart' : 'Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
