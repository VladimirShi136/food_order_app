/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  if (!collection.fields.getByName("phone")) {
    collection.fields.add(new TextField({
      name: "phone",
      required: false,
      max: 32,
    }))
  }

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")
  collection.fields.removeByName("phone")
  return app.save(collection)
})
