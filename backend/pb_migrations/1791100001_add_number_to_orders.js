/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("orders")

  if (!collection.fields.getByName("number")) {
    collection.fields.add(new NumberField({
      name: "number",
      onlyInt: true,
      min: 0,
    }))
  }

  // Номер заказа уникален (заказы без номера не учитываются)
  collection.addIndex("idx_orders_number", true, "number", "number > 0")

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("orders")
  collection.removeIndex("idx_orders_number")
  collection.fields.removeByName("number")
  return app.save(collection)
})
