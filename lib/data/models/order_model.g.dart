// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 4;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      orderId: fields[0] as String,
      orderNumber: fields[1] as String,
      customerName: fields[2] as String,
      customerPhone: fields[3] as String,
      deliveryAddress: fields[4] as String,
      addressCoordinates: (fields[5] as Map?)?.cast<String, double>(),
      orderItems: (fields[6] as List).cast<OrderItem>(),
      totalAmount: fields[7] as double,
      paymentMethod: fields[8] as PaymentMethod,
      paymentStatus: fields[9] as PaymentStatus,
      pickupLocationCode: fields[10] as String,
      assignedTo: fields[11] as String?,
      status: fields[12] as OrderStatus,
      timeline: (fields[13] as List).cast<StatusChange>(),
      deliveryOtp: fields[14] as String?,
      deliveryProofUrl: fields[15] as String?,
      specialInstructions: fields[16] as String?,
      createdAt: fields[17] as DateTime,
      deliveredAt: fields[18] as DateTime?,
      slaTime: fields[19] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.customerPhone)
      ..writeByte(4)
      ..write(obj.deliveryAddress)
      ..writeByte(5)
      ..write(obj.addressCoordinates)
      ..writeByte(6)
      ..write(obj.orderItems)
      ..writeByte(7)
      ..write(obj.totalAmount)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.paymentStatus)
      ..writeByte(10)
      ..write(obj.pickupLocationCode)
      ..writeByte(11)
      ..write(obj.assignedTo)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.timeline)
      ..writeByte(14)
      ..write(obj.deliveryOtp)
      ..writeByte(15)
      ..write(obj.deliveryProofUrl)
      ..writeByte(16)
      ..write(obj.specialInstructions)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.deliveredAt)
      ..writeByte(19)
      ..write(obj.slaTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 5;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      itemId: fields[0] as String,
      itemName: fields[1] as String,
      quantity: fields[2] as int,
      price: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusChangeAdapter extends TypeAdapter<StatusChange> {
  @override
  final int typeId = 6;

  @override
  StatusChange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatusChange(
      status: fields[0] as OrderStatus,
      timestamp: fields[1] as DateTime,
      notes: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StatusChange obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusChangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 7;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.newOrder;
      case 1:
        return OrderStatus.assigned;
      case 2:
        return OrderStatus.accepted;
      case 3:
        return OrderStatus.pickupPending;
      case 4:
        return OrderStatus.pickedUp;
      case 5:
        return OrderStatus.inTransit;
      case 6:
        return OrderStatus.delivered;
      case 7:
        return OrderStatus.completed;
      default:
        return OrderStatus.newOrder;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.newOrder:
        writer.writeByte(0);
        break;
      case OrderStatus.assigned:
        writer.writeByte(1);
        break;
      case OrderStatus.accepted:
        writer.writeByte(2);
        break;
      case OrderStatus.pickupPending:
        writer.writeByte(3);
        break;
      case OrderStatus.pickedUp:
        writer.writeByte(4);
        break;
      case OrderStatus.inTransit:
        writer.writeByte(5);
        break;
      case OrderStatus.delivered:
        writer.writeByte(6);
        break;
      case OrderStatus.completed:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 8;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.online;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.online:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentStatusAdapter extends TypeAdapter<PaymentStatus> {
  @override
  final int typeId = 9;

  @override
  PaymentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.cashCollected;
      case 2:
        return PaymentStatus.onlinePaid;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentStatus obj) {
    switch (obj) {
      case PaymentStatus.pending:
        writer.writeByte(0);
        break;
      case PaymentStatus.cashCollected:
        writer.writeByte(1);
        break;
      case PaymentStatus.onlinePaid:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
