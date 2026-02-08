import 'package:hive/hive.dart';
import 'budget.dart';

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 1; // Unique ID for this type

  @override
  Budget read(BinaryReader reader) {
    return Budget(
      id: reader.readString(),
      category: reader.readString(),
      amount: reader.readDouble(),
      period: reader.readString(),
      createdDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.category);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.period);
    writer.writeInt(obj.createdDate.millisecondsSinceEpoch);
  }
}
