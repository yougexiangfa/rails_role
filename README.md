# RailsRole

RailsRole 是一个基于Controller/Action的Rails权限控制系统，开箱即用，全程UI配置。
 
## 特性
* 没有权限的链接不显示，不增加一行代码
 
## 默认规则

* 具有编辑权限，则具有读的权限，所以默认对所有规则包含 `admin` 和 `read` 两个rule；

* 记录创建者同样具有对此记录的 admin 权限；


## 使用方式

### Controller

```ruby
# without params
before_action :require_role
  
# with params
before_action do |t|
  require_role params.permit!
end

# default role user method, you can over
def rails_role_user
  current_user 
end
```
 
 ## License
 The gem is available as open source under the terms of the [LGPL-3.0](https://opensource.org/licenses/LGPL-3.0).
