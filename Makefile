.PHONY: validate package bootstrap kvm import deploy hooks attach detach query test

validate:
	bash scripts/validate.sh

test:
	node tests/evaluate-governance.test.js

package:
	bash scripts/package-sharedflow.sh

kvm:
	bash scripts/create-kvm.sh
	bash scripts/put-kvm-config.sh

import:
	bash scripts/import-sharedflow.sh

deploy:
	bash scripts/deploy-sharedflow.sh

hooks:
	bash scripts/get-flow-hooks.sh

attach:
	bash scripts/attach-flow-hook.sh

detach:
	bash scripts/detach-flow-hook.sh

query:
	bash scripts/query-usage.sh

bootstrap:
	bash scripts/bootstrap.sh
