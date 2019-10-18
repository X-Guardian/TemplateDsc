# culture="en-US"
ConvertFrom-StringData @'
    GettingResourceMessage                   = Getting '{0}'. (ENS0001)
    SettingResourceMessage                   = Setting '{0}' property '{1}' to '{2}'. (ENS0002)
    AddingResourceMessage                    = Adding '{0}' to Application Group '{1}'. (ENS0003)
    RemovingResourceMessage                  = Removing '{0}' from Application Group '{1}'. (ENS0004)
    ResourceInDesiredStateMessage            = '{0}' in the desired state. (ENS0005)
    ResourcePropertyNotInDesiredStateMessage = '{0}' Property '{1}' is not in the desired state. Expected: '{2}', Actual: '{3}'. (ENS0006)
    ResourceExistsButShouldNotMessage        = '{0}' exists but should not. (ENS0007)
    ResourceDoesNotExistButShouldMessage     = '{0}' does not exist but should. (ENS0008)
    ResourceDoesNotExistAndShouldNotMessage  = '{0}' does not exist and should not. (ENS0009)
'@
