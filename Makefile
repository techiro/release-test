.PHONY: sync

# Sync resources from release-test-server repository
sync:
ifeq ($(filter-out $@,$(MAKECMDGOALS)), server-release)
	@echo "Syncing server resources..."
	@curl -s -L -H "Accept: application/vnd.github.v3.raw" \
		-H "Authorization: token $${GITHUB_TOKEN}" \
		-o release-server.md \
		https://api.github.com/repos/techiro/release-test-server/contents/release-server.md
	@echo "Server resources synced successfully!"
else
	@echo "Please specify what to sync. Example: make sync server-release"
endif

# This is a special target to handle arguments
%:
	@: