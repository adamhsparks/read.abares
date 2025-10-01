# .map_verbosity returns correct mappings for 'quiet'

    Code
      .map_verbosity("quiet")
    Output
      $rlib_message_verbosity
      [1] "quiet"
      
      $rlib_warning_verbosity
      [1] "quiet"
      
      $warn
      [1] -1
      
      $datatable.showProgress
      [1] FALSE
      

# .map_verbosity returns correct mappings for 'minimal'

    Code
      .map_verbosity("minimal")
    Output
      $rlib_message_verbosity
      [1] "minimal"
      
      $rlib_warning_verbosity
      [1] "verbose"
      
      $warn
      [1] 0
      
      $datatable.showProgress
      [1] FALSE
      

# .map_verbosity returns correct mappings for 'verbose'

    Code
      .map_verbosity("verbose")
    Output
      $rlib_message_verbosity
      [1] "verbose"
      
      $rlib_warning_verbosity
      [1] "verbose"
      
      $warn
      [1] 0
      
      $datatable.showProgress
      [1] TRUE
      

# .map_verbosity defaults to 'verbose' for unknown input

    Code
      .map_verbosity("loud")
    Output
      $rlib_message_verbosity
      [1] "verbose"
      
      $rlib_warning_verbosity
      [1] "verbose"
      
      $warn
      [1] 0
      
      $datatable.showProgress
      [1] TRUE
      

# .map_verbosity handles NULL input

    Code
      .map_verbosity(NULL)
    Output
      $rlib_message_verbosity
      [1] "verbose"
      
      $rlib_warning_verbosity
      [1] "verbose"
      
      $warn
      [1] 0
      
      $datatable.showProgress
      [1] TRUE
      

# .init_read_abares_options sets expected options

    Code
      opts
    Output
      $read.abares.user_agent
      [1] "read.abares R package 2.0.0 DEV https://github.com/adamhsparks/read.abares"
      
      $read.abares.timeout
      [1] 5000
      
      $read.abares.max_tries
      [1] 3
      
      $read.abares.verbosity
      [1] "verbose"
      
      $rlib_message_verbosity
      [1] "verbose"
      
      $rlib_warning_verbosity
      [1] "verbose"
      
      $warn
      [1] 0
      
      $datatable.showProgress
      [1] TRUE
      

