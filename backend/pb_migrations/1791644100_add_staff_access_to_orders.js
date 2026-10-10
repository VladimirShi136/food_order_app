/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const staff = new Collection({
    type: "auth",
    name: "staff",
    listRule: null,
    viewRule: null,
    createRule: null,
    updateRule: null,
    deleteRule: null,
    authRule: "",
    manageRule: null,
    fields: [
      { type: "text", name: "name", max: 100 },
    ],
    passwordAuth: {
      enabled: true,
      identityFields: ["email"],
    },
  })
  app.save(staff)

  const orders = app.findCollectionByNameOrId("orders")
  orders.listRule =
    'user = @request.auth.id || @request.auth.collectionName = "staff"'
  orders.viewRule =
    'user = @request.auth.id || @request.auth.collectionName = "staff"'
  orders.updateRule = '@request.auth.collectionName = "staff"'
  app.save(orders)

  const orderItems = app.findCollectionByNameOrId("order_items")
  orderItems.listRule =
    'order.user = @request.auth.id || @request.auth.collectionName = "staff"'
  orderItems.viewRule =
    'order.user = @request.auth.id || @request.auth.collectionName = "staff"'

  return app.save(orderItems)
}, (app) => {
  const orders = app.findCollectionByNameOrId("orders")
  orders.listRule = "user = @request.auth.id"
  orders.viewRule = "user = @request.auth.id"
  orders.updateRule = null
  app.save(orders)

  const orderItems = app.findCollectionByNameOrId("order_items")
  orderItems.listRule = "order.user = @request.auth.id"
  orderItems.viewRule = "order.user = @request.auth.id"
  app.save(orderItems)

  return app.delete(app.findCollectionByNameOrId("staff"))
})
