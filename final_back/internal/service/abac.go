package service

import (
	"github.com/kakimnsnv/ios_final_back/internal/models"
)

// HasPermission checks if a user has permission to perform an action on a resource
// For resource-specific checks, provide the data parameter
func HasPermission(userWR *models.User, resource models.ResourceType, action models.ActionType, data interface{}) bool {
	for _, role := range userWR.Roles {
		resourcePerms, ok := ROLES[role]
		if !ok {
			continue
		}

		actionPerms, ok := resourcePerms[resource]
		if !ok {
			continue
		}

		permission, ok := actionPerms[action]
		if !ok {
			continue
		}

		switch p := permission.(type) {
		case BooleanCheck:
			if bool(p) {
				return true
			}
		case UserCheck:
			if resource, ok := data.(models.User); ok && p(userWR, resource) {
				return true
			}
		}
	}

	return false
}

const (
	RoleAdmin     models.Role = "admin"
	RoleModerator models.Role = "moderator"
	RoleUser      models.Role = "user"
)

const (
	ResourceUser   models.ResourceType = "user"
	ResourceMovie  models.ResourceType = "movie"
	ResourceReview models.ResourceType = "review"
)

const (
	ActionView   models.ActionType = "view"
	ActionCreate models.ActionType = "create"
	ActionUpdate models.ActionType = "update"
	ActionDelete models.ActionType = "delete"
)

// BooleanCheck is a simple boolean permission check
type BooleanCheck bool
type UserCheck func(user *models.User, target models.User) bool
type ReviewCheck func(user *models.User, target models.Review) bool

// ROLES defines the permission matrix for all roles
var ROLES = initRoles()

func initRoles() models.RolePermissions {
	return models.RolePermissions{
		RoleAdmin: {
			ResourceUser: {
				ActionCreate: BooleanCheck(true),
				ActionView:   BooleanCheck(true),
				ActionUpdate: BooleanCheck(true),
				ActionDelete: BooleanCheck(true),
			},
			ResourceMovie: {
				ActionCreate: BooleanCheck(true),
				ActionView:   BooleanCheck(true),
				ActionUpdate: BooleanCheck(true),
				ActionDelete: BooleanCheck(true),
			},
			ResourceReview: {
				ActionCreate: BooleanCheck(true),
				ActionView:   BooleanCheck(true),
				ActionUpdate: BooleanCheck(true),
				ActionDelete: BooleanCheck(true),
			},
		},
		RoleModerator: {
			ResourceUser: {
				ActionView:   BooleanCheck(true),
				ActionUpdate: BooleanCheck(true),
				ActionDelete: BooleanCheck(true),
			},
			ResourceMovie: {
				ActionCreate: BooleanCheck(true),
				ActionView:   BooleanCheck(true),
				ActionUpdate: BooleanCheck(true),
				ActionDelete: BooleanCheck(true),
			},
			ResourceReview: {
				ActionView:   BooleanCheck(true),
				ActionDelete: BooleanCheck(true),
			},
		},
		RoleUser: {
			ResourceUser: {
				ActionCreate: BooleanCheck(true),
				ActionView:   BooleanCheck(true),
				ActionUpdate: UserCheck(func(user *models.User, target models.User) bool {
					return user.ID == target.ID
				}),
				ActionDelete: UserCheck(func(user *models.User, target models.User) bool {
					return user.ID == target.ID
				}),
			},
			ResourceMovie: {
				ActionView: BooleanCheck(true),
			},
			ResourceReview: {
				ActionCreate: BooleanCheck(true),
				ActionView: ReviewCheck(func(user *models.User, target models.Review) bool {
					return !target.IsPrivate || target.OwnerID == *user.ID
				}),
				ActionUpdate: ReviewCheck(func(user *models.User, target models.Review) bool {
					return target.OwnerID == *user.ID
				}),
				ActionDelete: ReviewCheck(func(user *models.User, target models.Review) bool {
					return target.OwnerID == *user.ID
				}),
			},
		},
	}
}
