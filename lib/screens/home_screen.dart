import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Promo {
  final String title;
  final String description;
  final IconData icon;

  const Promo({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<Promo> samplePromos = [
  Promo(
    title: 'Комбо дня −15%',
    description:
        'Бургер + картофель фри + напиток по специальной цене до конца недели',
    icon: Icons.local_fire_department,
  ),
  Promo(
    title: 'Новинка в меню',
    description: 'Острая шаурма с соусом чили — попробуйте уже сегодня',
    icon: Icons.whatshot,
  ),
  Promo(
    title: 'Самовывоз без ожидания',
    description: 'Оформите заказ заранее и заберите точно к нужному времени',
    icon: Icons.storefront,
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Новости и акции', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...samplePromos.map(
          (promo) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(promo.icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}