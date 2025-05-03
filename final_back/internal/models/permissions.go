package models

// PermissionCheck is a function that checks if user has permission for a resource
type PermissionCheck interface{}

// rolePermissions defines the permission structure for roles
type RolePermissions map[Role]ResourcePermissions
type ResourcePermissions map[ResourceType]ActionPermissions
type ActionPermissions map[ActionType]PermissionCheck
