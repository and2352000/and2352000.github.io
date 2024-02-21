.DEFAULT_GOAL := default

.PHONY: dev # dev run
dev:
	hugo server
default:
	@cat Makefile | grep '^.PHONY: .* #' | sed 's/\.PHONY: \(.*\) # \(.*\)/\1: \2/' | expand -t20
