/// <reference path="../pb_data/types.d.ts" />

// Серверная защита заказов.
// Клиентскому приложению доверять нельзя: цену, номер и статус заказа
// определяет сервер, а не то, что прислал телефон.

// --- Новый заказ: владелец, статус и номер ставит сервер ---
onRecordCreateRequest((e) => {
  if (!e.auth) {
    throw new UnauthorizedError("Войдите в аккаунт, чтобы оформить заказ")
  }

  const row = new DynamicModel({ "max": 0 })
  e.app.db()
    .newQuery("SELECT COALESCE(MAX(number), 0) AS max FROM orders")
    .one(row)

  e.record.set("user", e.auth.id)
  e.record.set("status", "new")
  e.record.set("total_price", 0)
  e.record.set("number", row.max + 1)

  e.next()
}, "orders")

// --- Позиция заказа: цена и название берутся из меню, итог пересчитывается ---
onRecordCreateRequest((e) => {
  if (!e.auth) {
    throw new UnauthorizedError("Войдите в аккаунт, чтобы оформить заказ")
  }

  let order
  try {
    order = e.app.findRecordById("orders", e.record.getString("order"))
  } catch (_) {
    throw new BadRequestError("Заказ не найден")
  }
  if (order.getString("user") != e.auth.id) {
    throw new ForbiddenError("Это не ваш заказ")
  }
  if (order.getString("status") != "new") {
    throw new BadRequestError("Заказ уже принят, изменить его нельзя")
  }

  const quantity = e.record.getInt("quantity")
  if (quantity < 1 || quantity > 99) {
    throw new BadRequestError("Некорректное количество")
  }

  let dish
  try {
    dish = e.app.findRecordById("dishes", e.record.getString("dish"))
  } catch (_) {
    throw new BadRequestError("Блюдо не найдено")
  }
  if (!dish.getBool("is_available")) {
    throw new BadRequestError("Блюдо «" + dish.getString("name") + "» сейчас недоступно")
  }

  e.record.set("dish_name", dish.getString("name"))
  e.record.set("price_at_order", dish.getFloat("price"))

  e.next()

  // Пересчёт итога заказа на сервере
  const items = e.app.findRecordsByFilter(
    "order_items", "order = {:order}", "", 1000, 0, { "order": order.id }
  )
  let total = 0
  for (const item of items) {
    total += item.getFloat("price_at_order") * item.getInt("quantity")
  }
  order.set("total_price", total)
  e.app.save(order)
}, "order_items")
