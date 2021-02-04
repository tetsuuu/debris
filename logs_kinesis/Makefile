
.PHONY: fmt
fmt:
	@terraform fmt -recursive ./modules
	@terraform fmt ./

.PHONY: plan
plan:
	@if ./is_changed $(ENV); then \
	  cd $(ENV) && $(MAKE) plan; \
	else \
	  echo Nop; \
	fi \
