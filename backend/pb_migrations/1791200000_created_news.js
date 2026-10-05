/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const dishes = app.findCollectionByNameOrId("dishes")

  const collection = new Collection({
    type: "base",
    name: "news",
    // Читают все, но только опубликованное и с неистёкшим сроком.
    listRule: 'is_published = true && (expires_at = "" || expires_at > @now)',
    viewRule: 'is_published = true && (expires_at = "" || expires_at > @now)',
    // Создавать, менять и удалять может только суперпользователь.
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      { type: "text", name: "title", required: true, max: 120 },
      { type: "text", name: "body", max: 2000 },
      {
        type: "file",
        name: "image",
        maxSelect: 1,
        maxSize: 5242880,
        mimeTypes: ["image/jpeg", "image/png", "image/webp"],
      },
      {
        type: "select",
        name: "kind",
        required: true,
        maxSelect: 1,
        values: ["promo", "news"],
      },
      { type: "bool", name: "is_published" },
      { type: "bool", name: "pinned" },
      { type: "date", name: "expires_at" },
      {
        type: "relation",
        name: "dishes",
        collectionId: dishes.id,
        maxSelect: 10,
        cascadeDelete: false,
      },
      { type: "autodate", name: "created", onCreate: true },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
    ],
  })

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("news")
  return app.delete(collection)
})
