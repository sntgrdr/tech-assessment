import { Card, CardBody } from '../ui/Card';

const StatsCard = ({ title, value, icon, color = 'blue', trend, isActive }) => {
  const colorClasses = {
    blue: 'bg-blue-500',
    green: 'bg-green-500',
    yellow: 'bg-yellow-500',
    red: 'bg-red-500',
    purple: 'bg-purple-500',
    indigo: 'bg-indigo-500',
  };

  const bgColorClasses = {
    blue: 'bg-blue-50',
    green: 'bg-green-50',
    yellow: 'bg-yellow-50',
    red: 'bg-red-50',
    purple: 'bg-purple-50',
    indigo: 'bg-indigo-50',
  };

  const activeBgClasses = {
    blue: 'bg-blue-100 border-blue-200',
    green: 'bg-green-100 border-green-200',
    yellow: 'bg-yellow-100 border-yellow-200',
    red: 'bg-red-100 border-red-200',
    purple: 'bg-purple-100 border-purple-200',
    indigo: 'bg-indigo-100 border-indigo-200',
  };

  const textColorClasses = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    yellow: 'text-yellow-600',
    red: 'text-red-600',
    purple: 'text-purple-600',
    indigo: 'text-indigo-600',
  };

  return (
    <Card className={`transition-colors duration-200 ${isActive ? activeBgClasses[color] + ' border-2 shadow-md' : 'border-transparent'}`}>
      <CardBody>
        <div className="flex items-center">
          <div className={`flex-shrink-0 ${bgColorClasses[color]} p-3 rounded-lg`}>
            <div className={`w-6 h-6 ${colorClasses[color]} rounded-full flex items-center justify-center`}>
              {icon}
            </div>
          </div>
          <div className="ml-5 w-0 flex-1">
            <dl>
              <dt className="text-sm font-medium text-gray-500 truncate">
                {title}
              </dt>
              <dd className="flex items-baseline">
                <div className="text-2xl font-semibold text-gray-900">
                  {value}
                </div>
                {trend && (
                  <div className={`ml-2 flex items-baseline text-sm font-semibold ${textColorClasses[color]}`}>
                    {trend}
                  </div>
                )}
              </dd>
            </dl>
          </div>
        </div>
      </CardBody>
    </Card>
  );
};

export default StatsCard;
