import { useBackend } from '../backend';
import { Button, Box } from '../components';
import { Window } from '../layouts';

import '../styles/MedBot.scss';

type Data = {
	on: boolean;
	open: boolean;
	locked: boolean;
	health: number;
	maxhealth: number;
	remote_disabled: boolean;

	canhack: boolean;
	emagged: boolean;

	heal_threshold: number;
	injection_amount: number;

	use_beaker: boolean;
	treat_virus: boolean;
	shut_up: boolean;
	declare_crit: boolean;
	auto_patrol: boolean;
	stationary_mode: boolean;

	beaker: boolean;
	beaker_volume: number;
	beaker_max: number;

	noaccess?: boolean;
};


export const MedBot = () => {

	const { act, data } = useBackend<Data>();

	const {
		on,
		open,
		locked,

		canhack,
		emagged,

		health,
		maxhealth,
		remote_disabled,

		heal_threshold,
		injection_amount,

		use_beaker,
		treat_virus,
		shut_up,
		declare_crit,
		auto_patrol,
		stationary_mode,

		beaker,
		beaker_volume,
		beaker_max,

		noaccess,
	} = data;


	return (
		<Window
			title="Медицинский бот"
			width={500}
			height={800}
		>

			<Window.Content className="medBot">


				<Box className="header">

					<Box className="title">
						МЕДИЦИНСКИЙ БОТ
					</Box>

					<Box className="sub">
						MEDICAL SUPPORT SYSTEM v1.1
					</Box>

				</Box>



				<Box className="systemCore">

					<Box
						className={
							on
								? "coreStatus online"
								: "coreStatus offline"
						}
					>

						{on
							? "СИСТЕМА АКТИВНА"
							: "СИСТЕМА ОТКЛЮЧЕНА"}

					</Box>



					<Box
						className="powerToggle"
						onClick={() => act("power")}
					>

						<Box className="toggleLabel">
							ПИТАНИЕ
						</Box>


						<Box className="toggleBody">

							<Box
								className={
									on
										? "toggleSwitch switchOn"
										: "toggleSwitch"
								}
							/>

						</Box>

					</Box>


				</Box>




				<Box
					className={
						locked
							? "accessStatus lockedStatus"
							: "accessStatus unlockedStatus"
					}
				>

					<Box className="accessLabel">
						ДОСТУП
					</Box>


					<Box className="accessValue">

						<Box className="accessDot"/>

						{
							locked
								? "УПРАВЛЕНИЕ ЗАБЛОКИРОВАНО"
								: "ПОЛНЫЙ ДОСТУП"
						}

					</Box>


				</Box>




				<Box className="layout">


					<Box className="panel">


						<Box className="panelTitle">
							УПРАВЛЕНИЕ ЛЕЧЕНИЕМ
						</Box>



						<Button.Checkbox
							fluid
							checked={use_beaker}
							disabled={noaccess}
							onClick={() => act("use_beaker")}
						>
							Использовать ёмкость
						</Button.Checkbox>



						<Button.Checkbox
							fluid
							checked={treat_virus}
							disabled={noaccess}
							onClick={() => act("virus")}
						>
							Лечение вирусов
						</Button.Checkbox>

						<Button.Checkbox
							fluid
							checked={!remote_disabled}
							disabled={noaccess}
							onClick={() => act('disableremote')}
						>
							Подключение ИИ
						</Button.Checkbox>


						<Button.Checkbox
							fluid
							checked={!shut_up}
							disabled={noaccess}
							onClick={() => act("togglevoice")}
						>
							Голосовой модуль
						</Button.Checkbox>



						<Button.Checkbox
							fluid
							checked={declare_crit}
							disabled={noaccess}
							onClick={() => act("critalerts")}
						>
							Оповещение о критических
						</Button.Checkbox>



						<Button.Checkbox
							fluid
							checked={auto_patrol}
							disabled={noaccess}
							onClick={() => act("patrol")}
						>
							Автопатрулирование
						</Button.Checkbox>



						<Button.Checkbox
							fluid
							checked={stationary_mode}
							disabled={noaccess}
							onClick={() => act("stationary")}
						>
							Стационарный режим
						</Button.Checkbox>


					</Box>





					<Box className="log">


						<Box className="panelTitle">
							ДИАГНОСТИКА
						</Box>



						<Box className="line">

							Питание

							<span className={on ? "good" : "bad"}>
								{on ? "НОРМА" : "ОТКЛЮЧЕНО"}
							</span>

						</Box>

						<Box className="line">
							Протоколы безопасности
							<span className={emagged ? 'bad' : 'good'}>
								{emagged ? 'НАРУШЕНЫ' : 'СТАБИЛЬНЫ'}
							</span>
						</Box>

<Box className="line">

	Удалённый доступ

	<span className={!remote_disabled ? "good" : "bad"}>
		{
			!remote_disabled
				? "РАЗРЕШЁН"
				: "ЗАПРЕЩЁН"
		}
	</span>



</Box>

						<Box className="healthBlock">


							<Box className="healthTitle">
								РЕАГЕНТНЫЙ МОДУЛЬ
							</Box>



							{
								beaker
									?

									<>

										<Box className="healthBar">

											<Box
												className="healthFill healthy"
												style={{
													width:
														`${(beaker_volume / beaker_max) * 100}%`,
												}}
											/>

										</Box>



										<Box className="good">
											{beaker_volume}/{beaker_max} ед.
										</Box>



										<Button
											fluid
											color="bad"
											icon="eject"
											onClick={() => act("eject")}
										>
											Извлечь ёмкость
										</Button>


									</>


									:

									<Box className="bad">
										ЁМКОСТЬ НЕ УСТАНОВЛЕНА
									</Box>

							}

<Box className="healthBlock">

	<Box className="healthTitle">
		ЦЕЛОСТНОСТЬ КОРПУСА
	</Box>


	<Box className="healthBar">

		<Box
			className={
				health > maxhealth * 0.6
					? "healthFill healthy"
					: health > maxhealth * 0.3
						? "healthFill damaged"
						: "healthFill critical"
			}

			style={{
				width: `${(health / maxhealth) * 100}%`,
			}}

		/>

	</Box>

</Box>

						</Box>


					</Box>


				</Box>





				<Box className="danger">

	<Box className="dangerTitle">
		ПАРАМЕТРЫ ЛЕЧЕНИЯ
	</Box>


	<Box className="adjustRow">

		<Box className="adjustLabel">
			Порог лечения
		</Box>

		<Box className="adjustControls">

			<Button
				disabled={noaccess}
				onClick={() =>
					act("adj_threshold", {
						value: -5
					})
				}
			>
				-
			</Button>


			<Box className="adjustValue">
				{heal_threshold}%
			</Box>


			<Button
				disabled={noaccess}
				onClick={() =>
					act("adj_threshold", {
						value: 5
					})
				}
			>
				+
			</Button>

		</Box>

	</Box>



	<Box className="adjustRow">

		<Box className="adjustLabel">
			Объём инъекции
		</Box>


		<Box className="adjustControls">

			<Button
				disabled={noaccess}
				onClick={() =>
					act("adj_inject", {
						value: -5
					})
				}
			>
				-
			</Button>


			<Box className="adjustValue">
				{injection_amount}
			</Box>


			<Button
				disabled={noaccess}
				onClick={() =>
					act("adj_inject", {
						value: 5
					})
				}
			>
				+
			</Button>


		</Box>


	</Box>


</Box>
{!!canhack && (

	<Box className="danger">

		<Box className="dangerTitle">
			КРИТИЧЕСКИЙ ДОСТУП
		</Box>


		<Button
			fluid
			color="bad"
			icon="terminal"
			disabled={noaccess}
			onClick={() => act("hack")}
		>

			{emagged
				? "Восстановить систему"
				: "Взломать систему"}

		</Button>


	</Box>

)}

			</Window.Content>

		</Window>
	);
};
