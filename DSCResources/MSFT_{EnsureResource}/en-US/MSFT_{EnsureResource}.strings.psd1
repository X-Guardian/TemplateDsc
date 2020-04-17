# culture="en-US"
ConvertFrom-StringData @'
    GettingResourceMessage                    = Getting '{0}'. (TMP001)
    TestingResourceMessage                    = Testing '{0}'. (TMP002)
    SettingResourceMessage                    = Setting '{0}'. (TMP003)
    SettingResourcePropertyMessage            = Setting '{0}' property '{1}' to '{2}'. (TMP004)
    AddingResourceMessage                     = Adding '{0}'. (TMP005)
    RemovingResourceMessage                   = Removing '{0}'. (TMP006)
    ResourceInDesiredStateMessage             = '{0}' is in the desired state. (TMP007)
    ResourceNotInDesiredStateMessage          = '{0}' is not in the desired state. (TMP008)
    ResourceIsPresentButShouldBeAbsentMessage = '{0}' is present but should be absent. (TMP009)
    ResourceIsAbsentButShouldBePresentMessage = '{0}' is absent but should be present. (TMP010)

    GettingResourceErrorMessage               = Error getting '{0}'. (TMPERR001)
    SettingResourceErrorMessage               = Error setting '{0}'. (TMPERR002)
    RemovingResourceErrorMessage              = Error removing '{0}'. (TMPRR003)
    AddingResourceErrorMessage                = Error adding '{0}'. (TMPRR004)

    TargetResourcePresentDebugMessage         = '{0}' is Present. (TMPDBG001)
    TargetResourceAbsentDebugMessage          = '{0}' is Absent. (TMPDBG002)
    TargetResourceShouldBePresentDebugMessage = '{0}' should be Present. (TMPDBG003)
    TargetResourceShouldBeAbsentDebugMessage  = '{0}' should be Absent. (TMPDBG004)
'@
