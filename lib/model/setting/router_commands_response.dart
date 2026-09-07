class RouterCommandsResponse {
  final bool success;
  final RouterCommandsData? data;
  final String? message;
  final dynamic errors;
  final List<dynamic> filters;

  RouterCommandsResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    required this.filters,
  });

  factory RouterCommandsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RouterCommandsResponse(
      success: json['success'] == true,
      data: json['data'] is Map<String, dynamic>
          ? RouterCommandsData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      message: json['message']?.toString(),
      errors: json['errors'],
      filters: json['filters'] is List
          ? List<dynamic>.from(
              json['filters'] as List,
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'errors': errors,
      'filters': filters,
    };
  }
}

// ============================================================
// Router Commands Data
// ============================================================

class RouterCommandsData {
  final Map<String, RouterCommandCategory> commands;

  RouterCommandsData({
    required this.commands,
  });

  factory RouterCommandsData.fromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, RouterCommandCategory> commands = {};

    final commandsJson = json['commands'];

    if (commandsJson is Map) {
      commandsJson.forEach((key, value) {
        if (value is Map) {
          commands[key.toString()] = RouterCommandCategory.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    return RouterCommandsData(
      commands: commands,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commands': commands.map(
        (key, value) => MapEntry(
          key,
          value.toJson(),
        ),
      ),
    };
  }
}

// ============================================================
// Router Command Category
// ============================================================

class RouterCommandCategory {
  final String category;
  final String categoryDescription;
  final List<RouterCommand> commands;

  RouterCommandCategory({
    required this.category,
    required this.categoryDescription,
    required this.commands,
  });

  factory RouterCommandCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<RouterCommand> commands = [];

    final commandsJson = json['commands'];

    if (commandsJson is List) {
      for (final item in commandsJson) {
        if (item is Map) {
          commands.add(
            RouterCommand.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return RouterCommandCategory(
      category: json['category']?.toString() ?? '',
      categoryDescription: json['category_description']?.toString() ?? '',
      commands: commands,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'category_description': categoryDescription,
      'commands': commands
          .map(
            (command) => command.toJson(),
          )
          .toList(),
    };
  }
}

// ============================================================
// Router Command
// ============================================================

class RouterCommand {
  final int id;

  final String command;

  final String description;

  final Map<String, dynamic>? parameters;

  final String example;

  final String expectedOutput;

  final String notes;

  final String troubleshootingTips;

  final int requiresReboot;

  final int isDangerous;

  // ==========================================================
  // Requirements
  // ==========================================================

  final List<String> requiredCommands;

  final bool hasRequirements;

  RouterCommand({
    required this.id,
    required this.command,
    required this.description,
    this.parameters,
    required this.example,
    required this.expectedOutput,
    required this.notes,
    required this.troubleshootingTips,
    required this.requiresReboot,
    required this.isDangerous,
    required this.requiredCommands,
    required this.hasRequirements,
  });

  factory RouterCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    // ========================================================
    // Parameters
    // ========================================================

    Map<String, dynamic>? parameters;

    if (json['parameters'] is Map) {
      parameters = Map<String, dynamic>.from(
        json['parameters'] as Map,
      );
    }

    // ========================================================
    // Required Commands
    // ========================================================

    List<String> requiredCommands = [];

    if (json['required_commands'] is List) {
      requiredCommands = (json['required_commands'] as List)
          .map(
            (item) => item.toString(),
          )
          .toList();
    }

    // ========================================================
    // Return
    // ========================================================

    return RouterCommand(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(
                json['id']?.toString() ?? '',
              ) ??
              0,
      command: json['command']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      parameters: parameters,
      example: json['example']?.toString() ?? '',
      expectedOutput: json['expected_output']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      troubleshootingTips: json['troubleshooting_tips']?.toString() ?? '',
      requiresReboot: json['requires_reboot'] is int
          ? json['requires_reboot']
          : int.tryParse(
                json['requires_reboot']?.toString() ?? '',
              ) ??
              0,
      isDangerous: json['is_dangerous'] is int
          ? json['is_dangerous']
          : int.tryParse(
                json['is_dangerous']?.toString() ?? '',
              ) ??
              0,
      requiredCommands: requiredCommands,
      hasRequirements: json['has_requirements'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'command': command,
      'description': description,
      'parameters': parameters,
      'example': example,
      'expected_output': expectedOutput,
      'notes': notes,
      'troubleshooting_tips': troubleshootingTips,
      'requires_reboot': requiresReboot,
      'is_dangerous': isDangerous,
      'required_commands': requiredCommands,
      'has_requirements': hasRequirements,
    };
  }
}
