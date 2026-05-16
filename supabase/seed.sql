-- Deterministic seed data for Green Miles rewards catalog.
insert into public.rewards (title, description, points, image_url, is_active)
values
  (
    'Eco Water Bottle',
    'Reusable stainless steel bottle from a local eco partner.',
    120,
    'https://images.unsplash.com/photo-1523362628745-0c100150b504',
    true
  ),
  (
    'Transit Day Pass',
    'One-day city transit pass for buses and metro lines.',
    250,
    'https://images.unsplash.com/photo-1474487548417-781cb71495f3',
    true
  ),
  (
    'Bike Service Voucher',
    'Voucher for a basic bicycle tune-up at partner shops.',
    400,
    'https://images.unsplash.com/photo-1485965120184-e220f721d03e',
    true
  ),
  (
    'Tree Planting Donation',
    'Plant one tree through a verified environmental nonprofit.',
    550,
    'https://images.unsplash.com/photo-1473448912268-2022ce9509d8',
    true
  ),
  (
    'Eco Tote Bag',
    'Durable organic cotton tote bag with Green Miles branding.',
    180,
    'https://images.unsplash.com/photo-1591561954557-26941169b49e',
    true
  ),
  (
    'Community Cleanup Kit',
    'Cleanup kit with gloves, bags, and reflective vest.',
    700,
    'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5',
    true
  )
on conflict (title)
do update set
  description = excluded.description,
  points = excluded.points,
  image_url = excluded.image_url,
  is_active = excluded.is_active;
