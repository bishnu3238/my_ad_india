import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/plan_model.dart';
import 'package:my_ad/features/merchant/subscription/core/subscription_plan_provider.dart';
import 'package:my_ad/utils/widgets/primary_button.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionPlanProvider>().fetchSubscriptionPlans();
      context.read<SubscriptionPlanProvider>().fetchCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: theme.primary,
        foregroundColor: theme.onPrimary,
      ),
      body: Consumer<SubscriptionPlanProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error!.message}',
                    style: TextStyle(color: theme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchSubscriptionPlans();
                      provider.fetchCurrentSubscription();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.availablePlans.isEmpty) {
            return const Center(child: Text('No subscription plans available'));
          }

          return Column(
            children: [
              // Header with title and description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryContainer.withValues(alpha:0.3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Subscribe and enjoy unlimited services',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose the plan that works for you',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.onSurface.withValues(alpha:0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Current subscription info
              if (provider.currentSubscription != null) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryContainer.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: provider.isPlanExpired
                          ? theme.error.withValues(alpha:0.5)
                          : theme.primary.withValues(alpha:0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            provider.isPlanExpired
                                ? Icons.warning_amber_rounded
                                : Icons.verified_rounded,
                            color: provider.isPlanExpired
                                ? theme.error
                                : theme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Subscription',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Plan: ${provider.currentSubscription!.planName}',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valid until: ${provider.currentSubscription!.endDate.toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: provider.isPlanExpired
                              ? theme.error
                              : theme.onSurface,
                          fontWeight: provider.isPlanExpired
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (provider.isPlanExpired) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your subscription has expired. Please renew to continue using all features.',
                          style: TextStyle(
                            color: theme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Available plans
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.availablePlans.length,
                  itemBuilder: (context, index) {
                    final plan = provider.availablePlans[index];
                    final isCurrentPlan = 
                        provider.currentSubscription?.planId == plan.id;
                    
                    return PlanCard(
                      plan: plan,
                      isCurrentPlan: isCurrentPlan,
                      onSubscribe: () => _subscribeToPlan(context, plan),
                      colorScheme: theme,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _subscribeToPlan(
    BuildContext context,
    SubscriptionPlanModel plan,
  ) async {
    final provider = context.read<SubscriptionPlanProvider>();
    final theme = Theme.of(context).colorScheme;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Subscription',
          style: TextStyle(color: theme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to subscribe to:',
              style: TextStyle(color: theme.onSurface.withValues(alpha:0.7)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryContainer.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.planName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Currency.rupeeSymbol}${plan.planRate} • ${plan.validity} days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: theme.onSurface)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Subscribe to the plan
    final result = await provider.subscribeToPlan(plan.id!);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: theme.error,
          ),
        );
      },
      (subscription) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to ${plan.planName}'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data
        provider.fetchCurrentSubscription();
        provider.checkPlanExpiration();
      },
    );
  }
}

class PlanCard extends StatefulWidget {
  final SubscriptionPlanModel plan;
  final bool isCurrentPlan;
  final VoidCallback onSubscribe;
  final ColorScheme colorScheme;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onSubscribe,
    required this.colorScheme,
  });

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _showAllFeatures = false;
  static const int _initialFeatureCount = 3;

  @override
  Widget build(BuildContext context) {
    final theme = widget.colorScheme;
    final plan = widget.plan;
    
    // Create a list of features from plan activities
    final List<String> features = [
      if (plan.numberOfServices != null) 'Up to ${plan.numberOfServices} services',
      '${plan.validity} days validity',
      plan.profileAccess,
      // Additional features from plan_master_activity table would be added here
      'Full access to service management',
      'Customer inquiry notifications',
      'Business analytics dashboard',
      'Service promotion tools',
      'Customer review management',
      'Service booking calendar',
      'Multiple location support',
    ];
    
    // Determine how many features to show
    final displayedFeatures = _showAllFeatures 
        ? features 
        : features.take(_initialFeatureCount).toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: widget.isCurrentPlan 
              ? Border.all(color: theme.primary, width: 2) 
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header with gradient background
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primary,
                    theme.primary.withBlue(  30),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: plan.banner.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(plan.banner),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha:0.3),
                          BlendMode.darken,
                        ),
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Plan name and price
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan.planName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${Currency.rupeeSymbol}${plan.planRate}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${plan.validity} days',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Current plan badge
                  if (widget.isCurrentPlan)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Plan content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offer badge
                  if (plan.offer.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              plan.offer,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (plan.description.isNotEmpty) ...[
                    Text(
                      plan.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.onSurface.withValues(alpha:0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Features heading
                  Text(
                    'What you get:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.surface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Features list
                  ...displayedFeatures.map((feature) => _buildFeatureRow(
                    Icons.check_circle_outline,
                    feature,
                    theme,
                  )),
                  
                  // View more/less button
                  if (features.length > _initialFeatureCount)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllFeatures = !_showAllFeatures;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showAllFeatures ? 'View less' : 'View more',
                            style: TextStyle(
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _showAllFeatures
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: theme.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Subscribe button
                  Center(
                    child: PrimaryButton(
                      text: widget.isCurrentPlan ? 'Current Plan' : 'Subscribe',
                      width: double.infinity,
                      onPressed:()=> widget.isCurrentPlan ? null : widget.onSubscribe,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, ColorScheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: theme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
