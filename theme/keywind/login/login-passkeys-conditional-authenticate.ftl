<#import "template.ftl" as layout>
<#import "components/atoms/form.ftl" as form>
<#import "components/atoms/input.ftl" as input>
<#import "components/atoms/button.ftl" as button>
<#import "components/atoms/button-group.ftl" as buttonGroup>
<#import "components/atoms/link.ftl" as link>

<@layout.registrationLayout script="dist/webAuthnAuthenticate.js" displayInfo=(realm.registrationAllowed && !registrationDisabled??); section>
  <#if section = "title">
    title
  <#elseif section = "header">
    ${kcSanitize(msg("passkey-login-title"))?no_esc}
  <#elseif section = "form">
    <div x-data="webAuthnAuthenticate">
      <form id="webauth" action="${url.loginAction}" method="post" x-ref="webAuthnForm">
        <input type="hidden" name="clientDataJSON" x-ref="clientDataJSONInput"/>
        <input type="hidden" name="authenticatorData" x-ref="authenticatorDataInput"/>
        <input type="hidden" name="signature" x-ref="signatureInput"/>
        <input type="hidden" name="credentialId" x-ref="credentialIdInput"/>
        <input type="hidden" name="userHandle" x-ref="userHandleInput"/>
        <input type="hidden" name="error" x-ref="errorInput"/>
      </form>

      <div class="mb-0">
        <#if authenticators??>
          <@form.kw id="authn_select">
            <#list authenticators.authenticators as authenticator>
              <@input.kw type="hidden" name="authn_use_chk" value="${authenticator.credentialId}"/>
            </#list>
          </@form.kw>

          <#if shouldDisplayAuthenticators?? && shouldDisplayAuthenticators>
            <div>
              <#if authenticators.authenticators?size gt 1>
                <p>${kcSanitize(msg("passkey-available-authenticators"))?no_esc}</p>
              </#if>

              <div>
                <#list authenticators.authenticators as authenticator>
                  <div>
                    <div>
                      <i class="properties[authenticator.transports.iconClass] || properties.kcWebAuthnDefaultIcon"></i>
                    </div>
                    <div>
                      <div>${kcSanitize(msg(authenticator.label))?no_esc}</div>
                      <#if authenticator.transports?? && authenticator.transports.displayNameProperties?has_content>
                        <div>
                          <#list authenticator.transports.displayNameProperties as nameProperty>
                            <span>${kcSanitize(msg(nameProperty))?no_esc}</span>
                            <#if nameProperty?has_next>
                              <span>, </span>
                            </#if>
                          </#list>
                        </div>
                      </#if>
                      <div>
                        <span>${kcSanitize(msg('passkey-createdAt-label'))?no_esc}</span>
                        <span>${kcSanitize(authenticator.createdAt)?no_esc}</span>
                      </div>
                    </div>
                  </div>
                </#list>
              </div>
            </div>
          </#if>
        </#if>

        <div>
          <#if realm.password>
            <@form.kw action="${url.loginAction}" method="post" style="display:none">
              <#if !usernameHidden??>
                <div>
                  <label for="username">${msg("passkey-autofill-select")}</label>
                  <@input.kw
                  tabindex="1"
                  id="username"
                  invalid=messagesPerField.existsError('username')
                  name="username"
                  value="${(login.username!'')}"
                  autocomplete="username webauthn"
                  type="text"
                  autofocus=true
                  />
                  <#if messagesPerField.existsError('username')>
                    <span
                      aria-live="polite">${kcSanitize(messagesPerField.get('username'))?no_esc}
                    </span>
                  </#if>
                </div>
              </#if>
            </@form.kw>
          </#if>

          <div style="display:none">
            <@buttonGroup.kw>
              <@button.kw type="button" @click="doAuthenticate" autofocus="autofocus">
                ${kcSanitize(msg("passkey-doAuthenticate"))}
              </@button.kw>
              <@button.kw type="button" autofocus="autofocus">
                ${kcSanitize(msg("passkey-doAuthenticate"))}
              </@button.kw>
            </@buttonGroup.kw>
          </div>
        </div>
      </div>
    </div>

    <script>
      document.addEventListener('alpine:init', () => {
        Alpine.data('webAuthnAuthenticate', () => ({
          challenge: '${challenge}',
          rpId: '${rpId}',
          userVerification: '${userVerification}',
          createTimeout: '${createTimeout}',
          isUserIdentified: ${isUserIdentified},
          login: {username: ''},
          authenticators: JSON.stringify(`${authenticators}`),
          shouldDisplayAuthenticators: ${shouldDisplayAuthenticators},
        }));
      });
    </script>
  <#elseif section = "info">
    <#if realm.registrationAllowed && !registrationDisabled??>
      <div id="kc-registration">
        <span>
          ${msg("noAccount")}
          <@link.kw tabindex="6" href="${url.registrationUrl}">
            ${msg("doRegister")}
          </@link.kw>
        </span>
      </div>
    </#if>
  </#if>
</@layout.registrationLayout>
