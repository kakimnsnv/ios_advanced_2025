package errs

import "errors"

var (
	AlreadyExists      = errors.New("already exists")
	NotFound           = errors.New("not found")
	InvalidCredentials = errors.New("invalid credentials")
	Forbidden          = errors.New("forbidden")
)
