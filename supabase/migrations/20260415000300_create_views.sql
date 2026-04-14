-- =========================================================
-- VIEWS
-- =========================================================

create view public.product_stock_summary as
select
  p.id as product_id,
  p.name,
  p.sku,
  p.status,
  coalesce(sum(
    case
      when sm.movement_type = 'in' then sm.quantity
      when sm.movement_type = 'out' then -sm.quantity
      when sm.movement_type = 'adjustment' then sm.quantity
      else 0
    end
  ), 0) as current_stock,
  p.minimum_stock
from public.products p
left join public.stock_movements sm on sm.product_id = p.id
group by p.id, p.name, p.sku, p.status, p.minimum_stock;
