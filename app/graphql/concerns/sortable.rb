module Sortable
  def apply_sort(scope, value, sort_mappings)
    sort_mappings.each do |field, methods|
      if value[field].present?
        direction = value[field]
        method_name = methods[direction]
        scope = send(method_name, scope) if method_name
      end
    end
    scope
  end

  private

  def apply_order_by_with_created_at_asc(scope)
    scope.order('created_at ASC')
  end

  def apply_order_by_with_created_at_desc(scope)
    scope.order('created_at DESC')
  end

  def apply_sort_with_price_asc(scope)
    scope.order('price ASC')
  end

  def apply_sort_with_price_desc(scope)
    scope.order('price DESC')
  end

  def apply_sort_with_room_class_asc(scope)
    scope.order(Arel.sql('CASE WHEN room_class = \'Economy\' THEN 1 WHEN room_class = \'Standard\' THEN 2 WHEN room_class = \'Luxury\' THEN 3 ELSE 4 END ASC'))
  end

  def apply_sort_with_room_class_desc(scope)
    scope.order(Arel.sql('CASE WHEN room_class = \'Economy\' THEN 1 WHEN room_class = \'Standard\' THEN 2 WHEN room_class = \'Luxury\' THEN 3 ELSE 4 END DESC'))
  end

  def apply_order_by_with_amount_due_asc(scope)
    scope.order('amount_due ASC')
  end

  def apply_order_by_with_amount_due_desc(scope)
    scope.order('amount_due DESC')
  end
end
