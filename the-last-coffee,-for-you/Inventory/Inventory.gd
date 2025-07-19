extends Resource

class_name Inventory

signal slot_updated

@export var slots: Array[slot]

func insert(item: Inventory_Item):
    for s in slots:
        if s.item == item:
            s.amount += 1
            emit_signal("slot_updated")
            return
    # If not found, add to first empty slot
    for s in slots:
        if s.item == null:
            s.item = item
            s.amount = 1
            emit_signal("slot_updated")
            return
