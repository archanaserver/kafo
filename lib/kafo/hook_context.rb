module Kafo
  class HookContext
    attr_reader :kafo

    def self.execute(kafo, &hook)
      # TODO can be removed in 0.6, is DEPRECATED since 0.5
      # instance_exec can be later changed to instance eval when people stop using |kafo| in their hooks
      # and rely only on hook context DSL
      if hook.arity > 0
        kafo.logger.warn "Hook '#{name}' is using block with arguments which is DEPRECATED, access to kafo instance is " +
                        "provided by hook DSL, please remove |kafo| from your hook block"
      end
      new(kafo).instance_exec(kafo, &hook)
    end

    def initialize(kafo)
      @kafo = kafo
    end

    # some of hooks won't print any message because logger is not yet configured
    # configuration of logger depends on application configration (log level etc.)
    # examples:
    #   logger.warn "this combindation of parameters is untested"
    def logger
      self.kafo.logger
    end

    # if you want to add new app_option be sure to do as soon as possible (usually boot hook)
    # otherwise it may be to late (e.g. when displaying help)
    # examples:
    #   app_option '--log-level', 'LEVEL', 'Log level for log file output', :default => config.app[:log_level]:
    #   app_option ['-n', '--noop'], :flag, 'Run puppet in noop mode?', :default => false
    def app_option(*args)
      self.kafo.class.app_option *args
    end

    # examples:
    #   app_value(:log_level)
    # note the dash to underscore convention
    def app_value(option)
      self.kafo.config.app[option.to_sym]
    end

    # examples:
    #   param('foreman', 'interface').value = 'eth0'
    #   param('foreman', 'interface').value = app_option('bind_on_interface')
    def param(module_name, parameter_name)
      self.kafo.param(module_name, parameter_name)
    end

    # You can add custom modules not explicitly enabled in answer file. This is especially
    # useful if you want to add your plugin to existing installer. This module will become
    # part of answer file so it also preserves parameter values between runs. It also list
    # its options in help output. You can also specify mapping for this module as a second
    # parameter.
    # examples:
    #   add_module('my_module')
    #   add_module('foreman::plugin::staypuft', {:dir_name => 'foreman', :manifest_name => 'plugin/staypuft'})
    def add_module(module_name, mapping = nil)
      self.kafo.config.add_mapping(module_name, mapping) if mapping
      self.kafo.add_module(module_name)
    end
  end
end