import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Customer management page for the airline system.
/// Handles adding, viewing, editing, and deleting customers.
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}